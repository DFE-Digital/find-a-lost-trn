# Analytics

Find a lost TRN sends data to BigQuery for the data team in two ways:

- **Database replication.** [Airbyte](https://github.com/DFE-Digital/dfe-analytics/blob/main/docs/airbyte.md) copies the database tables into BigQuery. Airbyte runs outside the app; this repository decides which columns it copies and which BigQuery hides.
- **Request events.** The [dfe-analytics](https://github.com/DFE-Digital/dfe-analytics) gem records every web request as an event.

The gem can also send an event for every database change. We switch that off, because Airbyte replaces it.

This page explains how both work, which data leaves the service, and what to do when the schema changes. No deployed environment sends anything yet.

## How request events work

1. After every controller action, `ApplicationController#trigger_request_event` builds an event. It holds the method, path, query string, referer, user agent, response status, an anonymised IP, the session ID, and the staff user's ID while staff are signed in.
2. `lib/dfe/analytics/filtered_request_event.rb` passes the query string, and the referring page's query string, through Rails' `filter_parameters`, so a parameter filtered from the logs is filtered from the event too. The gem's own event class doesn't filter, which is why we override it. Filtering the referer matters because Devise's password reset and invitation links carry live tokens. If the referer can't be parsed, the event leaves it out.
3. The app queues the event on the worker's `analytics` Sidekiq queue, and the worker sends it to BigQuery.

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

## Running locally

Analytics is off locally, because the flag is inactive. To send events from your machine:

1. Get a BigQuery key, following the [gem's BigQuery setup guide](https://github.com/DFE-Digital/dfe-analytics/blob/main/docs/google_cloud_bigquery_setup.md).
2. Set `BIGQUERY_API_JSON_KEY`, `BIGQUERY_PROJECT_ID`, `BIGQUERY_DATASET` and `BIGQUERY_TABLE_NAME` in `.env.development.local`.
3. Activate `send_analytics_events` in your local support interface.
4. Run Sidekiq, since the worker sends the events.
