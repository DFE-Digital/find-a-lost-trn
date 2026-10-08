# Analytics

Find a lost TRN sends data to BigQuery for the data team in two ways:

- **Database replication.** [Airbyte](https://github.com/DFE-Digital/dfe-analytics/blob/main/docs/airbyte.md) copies the database tables into BigQuery. Airbyte runs outside the app; this repository decides which columns it copies and which BigQuery hides.
- **Request events.** The [dfe-analytics](https://github.com/DFE-Digital/dfe-analytics) gem records every web request as an event.

The gem can also send an event for every database change. We switch that off, because Airbyte replaces it.

This page explains how both work, which data leaves the service, what to do when the schema changes, and how to switch an environment on or off.

## How request events work

1. After every controller action, `ApplicationController#trigger_request_event` builds an event. It holds the method, path, query string, referer, user agent, response status, an anonymised IP, the session ID, and the staff user's ID while staff are signed in.
2. `lib/dfe/analytics/filtered_request_event.rb` passes the query string, and the referring page's query string, through Rails' `filter_parameters`, so a parameter filtered from the logs is filtered from the event too. The gem's own event class doesn't filter, which is why we override it. Filtering the referer matters because Devise's password reset and invitation links carry live tokens. If the referer can't be parsed, the event leaves it out.
3. The app queues the event on the worker's `analytics` Sidekiq queue, and the worker sends it to the `events` table in the `faltrn_events_<environment>` dataset.

The worker authenticates to Google with Azure workload identity federation, so no keys are stored. Terraform creates the dataset and table, gives the worker that identity and sets `GOOGLE_CLOUD_CREDENTIALS` (`terraform/aks/dfe_analytics.tf`).

Events only go out while the `send_analytics_events` feature flag is active. It's inactive by default in every environment, and you can switch it in the support interface under `/support/features`.

**Only activate the flag in an environment that has BigQuery credentials.** Without them, every request queues a job that fails and retries.

## Which data leaves the service

| File                              | What it controls                                                                              |
| --------------------------------- | --------------------------------------------------------------------------------------------- |
| `config/analytics.yml`            | The columns Airbyte copies. Anything not listed stays in the service.                         |
| `config/analytics_hidden_pii.yml` | Copied columns that get the hidden policy tag, so only people approved for PII can read them. |
| `config/analytics_blocklist.yml`  | Columns deliberately not copied.                                                              |

The gem builds Airbyte's list of streams from `analytics.yml`, and applies the hidden policy tag to the columns in `analytics_hidden_pii.yml` after each sync.

The PII review in [#298](https://github.com/DFE-Digital/teaching-record-team-project-board/issues/298) decided which columns BigQuery hides. The review didn't cover these columns, so they stay in the blocklist until the data team decides on them:

- the raw DQT response
- rejected form values
- the TRN a user typed in
- staff sign-in IPs and unconfirmed emails

We never copy credentials (password hashes and tokens) or console audit text.

### When a migration adds a column

The app refuses to boot if a model attribute is in neither `analytics.yml` nor the blocklist. So for each new column, decide whether the data team needs it:

- To copy it, add it to `config/analytics.yml`. If it holds personal data, also add it to `config/analytics_hidden_pii.yml`.
- To keep it out, regenerate the blocklist:

  ```bash
  SUPPRESS_DFE_ANALYTICS_INIT=1 bin/rails dfe:analytics:regenerate_blocklist
  bin/lint
  ```

The check covers model attributes only. It skips tables without a model, and it logs instead of raising when the database is unreachable or has pending migrations. CI boots against a migrated database, so it catches a column you forgot.

A spec also fails if a hidden column isn't in `analytics.yml`. Without that check, the column would never reach BigQuery, so it would never be hidden either.

## How database replication works

1. Postgres runs with logical replication on (`pg_airbyte_enabled`), so it keeps every change in a replication slot, `airbyte_slot`, until Airbyte reads it.
2. Each namespace on the cluster has one Airbyte instance, which the infrastructure team runs. FaLTRN has a workspace in it, and terraform creates a source (our database), a destination (BigQuery) and a connection between them (`terraform/aks/airbyte.tf`).
3. Every 15 minutes, the connection copies new changes into the `faltrn_airbyte_<environment>` dataset. It appends rather than merges, so each table in BigQuery holds every version of each row.

On every deploy, terraform runs a Kubernetes job called `airbyte-stream-update`. The job runs `rake dfe:analytics:airbyte_deploy_tasks`, which queues a job on the worker. That job waits for migrations, refreshes the Airbyte connection so it picks up schema changes, runs a sync, and tags the hidden columns.

The worker tags the columns with the request events credentials. So terraform refuses `airbyte_enabled` without `enable_dfe_analytics_federated_auth`, and hands the app's own service account (`app-wif-faltrn-<environment>`) to the Airbyte module, which makes it an owner of its dataset.

## Switching analytics on for an environment

Each environment opts in separately, in two deploys. Airbyte has to wait for the first, for two reasons. Its module looks up the app's service account, which the first deploy creates. And its setup job creates the replication slot as soon as it runs: if Postgres hasn't yet restarted with logical replication, `psql` carries on past the error and exits 0, so terraform records the job as done and never reruns it.

Every deploy workflow needs to authenticate terraform to Google with this repository's workload identity provider, which a project owner sets up once with the `dfe_analytics` module's `authorise_workflow.sh`. The Google Cloud project needs a policy tag taxonomy with two hidden tags (one for the events table, one for the Airbyte tables) and a KMS key.

First, request events and logical replication:

1. In `terraform/aks/workspace_variables/<environment>.tfvars.json`, set `gcp_project_id`, `gcp_taxonomy_id`, `gcp_policy_tag_id` (the events table's tag), `gcp_keyring` and `gcp_key`, and set `enable_dfe_analytics_federated_auth` and `pg_airbyte_enabled` to `true`.

   **Turning on `pg_airbyte_enabled` restarts the database server several times.** Deploy in a window agreed with the infrastructure team.

2. Merge and deploy.
3. Activate `send_analytics_events` in the environment's support interface.

Then Airbyte, once the infrastructure team has created a FaLTRN workspace in the namespace's Airbyte instance and added `AIRBYTE-CLIENT-ID`, `AIRBYTE-CLIENT-SECRET` and `AIRBYTE-WORKSPACE-ID` to the environment's infra Key Vault:

4. In the same file, set `gcp_airbyte_policy_tag_id` (the Airbyte tables' tag), `airbyte_enabled` to `true` and `airbyte_connection_status` to `"active"`. If the module's resource names are too long for the environment name, set `airbyte_environment` to a shorter one, such as `"preprod"`.
5. Merge and deploy.
6. Check that the first sync shows in the Airbyte UI at `https://airbyte-<namespace>.<cluster domain>`, and that the worker logs show `AirbyteDeployJob` and the policy tag job finishing without errors. The `airbyte-stream-update` Kubernetes job only queues that work, so its success proves nothing about the sync or the tags.
7. Ask the data team to confirm that the data has arrived and the hidden columns are tagged.

## Switching analytics off

To stop request events, deactivate `send_analytics_events`. This takes effect immediately, with no deploy.

**While nothing reads `airbyte_slot`, Postgres keeps every change for it, and the database server's storage fills up.** Setting `airbyte_connection_status` to `"inactive"` stops reading, so only use it for a short pause, and make sure storage alerts are in place.

To remove replication, in this order:

1. Set `airbyte_connection_status` to `"inactive"` and deploy.
2. Drop the slot and publication from a console on the database:

   ```sql
   ALTER ROLE CURRENT_USER WITH REPLICATION;
   SELECT pg_drop_replication_slot('airbyte_slot');
   ALTER ROLE CURRENT_USER WITH NOREPLICATION;
   DROP PUBLICATION airbyte_publication;
   ```

   The database user only has the replication attribute while it needs it, which is how the Airbyte module creates the slot too.

3. Set `airbyte_enabled` to `false` and deploy. **This destroys the Airbyte dataset in BigQuery, including its data.** Check with the data team first.
4. Set `pg_airbyte_enabled` to `false` and deploy, which restarts the database server. Postgres won't start with logical replication off while a logical slot still exists, which is why the slot goes first.

Setting `enable_dfe_analytics_federated_auth` to `false` fails while the events table exists, because the table has deletion protection. Once the data team agrees, ask the infrastructure team to delete the table, then deploy.

## Running locally

Analytics is off locally, because the flag is inactive. To send events from your machine:

1. Get a BigQuery key, following the [gem's BigQuery setup guide](https://github.com/DFE-Digital/dfe-analytics/blob/main/docs/google_cloud_bigquery_setup.md).
2. Set `BIGQUERY_API_JSON_KEY`, `BIGQUERY_PROJECT_ID`, `BIGQUERY_DATASET` and `BIGQUERY_TABLE_NAME` in `.env.development.local`.
3. Activate `send_analytics_events` in your local support interface.
4. Run Sidekiq, since the worker sends the events.
