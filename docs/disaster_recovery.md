# Disaster recovery

The systems are built with resiliency in mind, but they may [fail in different ways](https://technical-guidance.education.gov.uk/infrastructure/disaster-recovery/) and could cause an incident.

This document covers the most critical scenarios and should be used in case of an incident. They should be regularly tested by following the [Disaster recovery testing document](disaster-recovery-testing.md).

## Permissions

Before you can carry out any of the recovery steps below, you need access to the following:

- **Azure portal** — you need access to the relevant Azure subscriptions (`s189-teacher-services-cloud-production` and/or `s189-teacher-services-cloud-test`) with sufficient permissions to view and manage resources such as Postgres flexible servers, storage accounts, and diagnostic settings.
- **GitHub** — you need write access to the [find-a-lost-trn](https://github.com/DFE-Digital/find-a-lost-trn) repository to trigger workflows, and admin access to update branch protection rules for the pipeline freeze.

If you don't have these permissions, contact your team lead or infrastructure team to get them set up before proceeding.

## Which scenario are you in?

If the Azure Postgres flexible server itself is gone — you can't find it in the Azure portal, or Azure reports the resource as deleted — you're dealing with [Scenario 1: Loss of database server](#scenario-1-loss-of-database-server).

If the server is still running but the data is wrong — records are missing, corrupted, or otherwise incorrect — you're dealing with [Scenario 2: Loss of data](#scenario-2-loss-of-data).

## Database Failure Scenarios

1. [Loss of database server](#scenario-1-loss-of-database-server)
2. [Loss of data](#scenario-2-loss-of-data)

## Scenario 1: [Loss of database server](https://technical-guidance.education.gov.uk/infrastructure/disaster-recovery/#loss-of-database-instance)

In this scenario, the [Azure Postgres flexible server](https://portal.azure.com/?feature.msaljs=true#browse/Microsoft.DBforPostgreSQL%2FflexibleServers) and the database it contains have been completely lost.

There are two main options for recovery.

1. Recover the deleted server from the Azure backups. These can be used to recover a dropped Azure Database for PostgreSQL flexible server resource within five days from the time of server deletion. Note that Microsoft do not guarantee this will work as there are other factors involved. See https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-restore-dropped-server
2. Recreate the Postgres server via terraform, and then restore from the nightly github workflow scheduled database backups. These backups are stored in [Azure storage accounts](https://portal.azure.com/?feature.msaljs=true#browse/Microsoft.Storage%2FStorageAccounts) and kept for 7 days.

Option 1 should be attempted first, as it can recover very close to the point of server loss, minimising any potential data loss. Option 2 would be used if the first option fails to work.

The steps involved in recovery are (choosing either option 1 or 2 for the postgres recreation):

1. [Start the incident process](#start-the-incident-process-if-not-already-in-progress)
1. [Stop the service](#stop-the-service)
1. [Freeze pipeline](#freeze-pipeline)
1. [Recreate the lost postgres database server](#recreate-the-lost-postgres-database-server)
   - [Option 1: Recover from Azure backups](#option-1-recover-from-azure-backups)
   - [Option 2: Recreate via terraform and restore from scheduled offline backup](#option-2-recreate-via-terraform-and-restore-from-scheduled-offline-backup)
     - [Recreate the postgres server via terraform](#step-1-recreate-the-postgres-server-via-terraform)
     - [Restore the data from previous backup in Azure storage](#step-2-restore-the-data-from-previous-backup-in-azure-storage)
1. [Restart applications](#restart-applications)
1. [Validate app](#validate-app)
1. [Unfreeze pipeline](#unfreeze-pipeline)

### Start the incident process (if not already in progress)

Follow the [incident playbook](https://tech-docs.teacherservices.cloud/operating-a-service/incident-playbook.html) and contact the relevant stakeholders as described in [create-an-incident-slack-channel-and-inform-the-stakeholders-comms-lead](https://tech-docs.teacherservices.cloud/operating-a-service/incident-playbook.html#4-create-an-incident-slack-channel-and-inform-the-stakeholders-comms-lead).

### Stop the service

Even though the database is gone, the application may still be running and showing errors to users. Stop the web app and workers to prevent this, and so users see a maintenance page rather than error screens.

e.g. [update namespace and deployment names as required, the below refers to the tra-test environment]

- `kubectl -n tra-test get deployments`
- `kubectl -n tra-test scale deployment find-a-lost-trn-test --replicas 0`
- `kubectl -n tra-test scale deployment find-a-lost-trn-test-worker --replicas 0`

### Freeze pipeline

Alert developers that no one should merge to main, this is to prevent automated deploys from interrupting the recovery process.

- In github setings, a user with repo admin privileges should update the _Branch protection rules_ and set required PR approvers to 6

### Recreate the lost postgres database server

Follow the steps for either Option 1 (to recover from azure backups) or Option 2 (to recreate via terraform and restore from scheduled offline backup). Details regarding which option to choose can be found at the start of this scenario.

#### Option 1: Recover from Azure backups

Run the [Recover deleted postgres database server workflow](https://github.com/DFE-Digital/find-a-lost-trn/actions/workflows/restore-deleted-postgres.yml) to recreate the missing postgres database.

| Required Parameter     | Description                                                      | Options                         |
| ---------------------- | ---------------------------------------------------------------- | ------------------------------- |
| Environment to restore | The environment to restore the database server in.               | test, preproduction, production |
| Confirm production     | A true/false confirmation if running in production.              | true, false                     |
| Restore point in time  | Restore point in time in UTC.<br/>See below for important notes. | e.g. 2024-07-24T06:00:00        |
| Server name to restore | The server name to be restored.                                  | See table below                 |

Finding the deletion timestamp:

1. In the [Azure portal](https://portal.azure.com/#blade/Microsoft_Azure_ActivityLog/ActivityLogBlade), go to **Monitor** then **Activity Log**.
2. Add filters for **Subscription** (the subscription hosting the deleted server) and **Operation** (`Delete PostgreSQL Server` / `Microsoft.DBforPostgreSQL/flexibleservers/delete`).
3. Select the deletion event and open the **JSON tab**. Copy the `submissionTimestamp` value — this is the time the server was deleted.

Restore point in time:

- The restore point provided should be at least 10 minutes after the `submissionTimestamp` and should be in the past, this is to provide time for the backup to become available.
- **Important:** You should convert the time to UTC before actually using it. When you record the time, note what timezone you are using. Especially during BST (British Summer Time).

Environment server names:

| Environment   | Server name          |
| ------------- | -------------------- |
| production    | s189p01-faltrn-pd-pg |
| preproduction | s189t01-faltrn-pp-pg |
| test          | s189t01-faltrn-ts-pg |

#### Option 2: Recreate via terraform and restore from scheduled offline backup

**Important:** Option 2 means restoring from the most recent nightly backup, so you will lose any data entered between that backup and the point of failure. Make sure you highlight this to the team and any affected users.

##### Recreate the postgres server via terraform

Note that recreating the database server via terraform can take a significant amount of time. Be prepared for this step to take a while.

Run the [deploy workflow](https://github.com/DFE-Digital/find-a-lost-trn/actions/workflows/build-and-deploy.yml) to recreate the missing postgres database as detailed below. This will create an empty database for us to restore the data into in the next step.

Check and delete any postgres diagnostics remaining for the deleted instance in https://portal.azure.com/#view/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/~/diagnosticsLogs as the later deploy to rebuild postgres will fail if it remains. e.g. search using subscription the appropriate subscription and resource group combination (see below) and look for enabled Diagnostic settings.

| Environment   | Subscription                           | Resource Group       |
| ------------- | -------------------------------------- | -------------------- |
| production    | s189-teacher-services-cloud-production | s189p01-faltrn-pd-rg |
| preproduction | s189-teacher-services-cloud-test       | s189t01-faltrn-pp-rg |
| test          | s189-teacher-services-cloud-test       | s189t01-faltrn-ts-rg |

##### Restore the data from previous backup in Azure storage

Run the [Restore database from Azure storage workflow](https://github.com/DFE-Digital/find-a-lost-trn/actions/workflows/database-restore.yml).

The workflow has a backup filename parameter. Leave it blank to use the default, which restores from the most recent automated nightly backup. The default only works with the automated nightly backups — if you need to restore from a manually triggered (adhoc) backup, you'll need to specify the adhoc backup file's name explicitly.

If you need to find the filename of a nightly backup, you can get it from the output of the [scheduled backup GitHub Action](https://github.com/DFE-Digital/find-a-lost-trn/actions/workflows/aks-db-backup.yml) workflow run that created it.

This step isn't required if using the restore-deleted-postgres workflow i.e. option 1 in the previous step.

### Restart applications

Scale the deployments back up to restore the service.

e.g. [update namespace and deployment names as required, the below refers to the tra-test environment]

- `kubectl -n tra-test get deployments`
- `kubectl -n tra-test scale deployment find-a-lost-trn-test --replicas 2`
- `kubectl -n tra-test scale deployment find-a-lost-trn-test-worker --replicas 1`

### Validate app

Confirm the app is working and you can see the restored data.

You may also want to check any healthcheck urls (e.g. /healthcheck), admin interfaces, api requests, etc.

Healthcheck URLs for different environments can be found at:

| Environment   | Healthcheck URL                                             |
| ------------- | ----------------------------------------------------------- |
| production    | https://find-a-lost-trn.education.gov.uk/health/all         |
| preproduction | https://preprod.find-a-lost-trn.education.gov.uk/health/all |
| test          | https://test.find-a-lost-trn.education.gov.uk/health/all    |

### Unfreeze pipeline

Alert developers that merge to main is allowed.

- In github settings, update the Branch protection rules and set required PR approvers back to 1

## Scenario 2: [Loss of data](https://technical-guidance.education.gov.uk/infrastructure/disaster-recovery/#data-corruption)

In the case of data loss or corruption, we need to recover the data as soon as possible in order to resume normal service.

The application database is an Azure flexible postgres server. This server has a point-in-time restore (PTR) ability with the resolution of 1 second, available between 5min and 7days. PTR allows you to restore the live server to a point-in-time on a new copy of the server. It does not update the live server itself in any way. Once the new server is available it can be accessed using [konduit.sh](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/scripts/konduit.sh) to check previous data, and data can then be recovered to the original server.

The goals of this scenario are:

- Create a separate new postgres database server
- Restore data from the current live database to the new postgres database server from a particular point in time
- Update data into the live database from the new PTR server

The steps involved in this are:

1. [Stop the service as soon as possible](#stop-the-service-as-soon-as-possible)
2. [Start the incident process](#start-the-incident-process-if-not-already-in-progress)
3. [Freeze pipeline](#freeze-pipeline)
4. [Back up the database (optional)](#back-up-the-database-optional)
5. [Validate data](#validate-data)
6. [Restore postgres database](#restore-postgres-database)
7. [Upload restored database to Azure storage](#upload-restored-database-to-azure-storage)
8. [Restore data into the live server](#restore-data-into-the-live-server)
9. [Restart applications](#restart-applications)
10. [Validate app](#validate-app)
11. [Unfreeze pipeline](#unfreeze-pipeline)
12. [Tidy up](#tidy-up)

### Stop the service as soon as possible

If the service is available, even in a degraded mode, there is a risk users may make edits and corrupt the data even more. Or they might access data they should not have access to. To prevent this, stop the web app and/or workers as soon as possible. This can be completed using the kubectl scale command

e.g. [update namespace and deployment names as required, the below refers to the tra-test environment]

- `kubectl -n tra-test get deployments`
- `kubectl -n tra-test scale deployment find-a-lost-trn-test --replicas 0`
- `kubectl -n tra-test scale deployment find-a-lost-trn-test-worker --replicas 0`

### Start the incident process (if not already in progress)

Follow the [incident playbook](https://tech-docs.teacherservices.cloud/operating-a-service/incident-playbook.html) and contact the relevant stakeholders as described in [create-an-incident-slack-channel-and-inform-the-stakeholders-comms-lead](https://tech-docs.teacherservices.cloud/operating-a-service/incident-playbook.html#4-create-an-incident-slack-channel-and-inform-the-stakeholders-comms-lead).

### Freeze pipeline

Alert developers that no one should merge to main. This is to prevent automated deploys from interrupting the recovery process, and also to prevent any further data corruption if the issue was caused by a recent change.

- In github setings, a user with repo admin privileges should update the _Branch protection rules_ and set required PR approvers to 6

### Back up the database (optional)

This step is optional, however if users have entered data or new users have signed up since the database corruption we don't want to lose that data and we may need to keep this data for reconciliation later on. To do that we need to back up the current state of the database before restoring the previous data. This backup can then be used to extract any new data entered since the corruption, and also to compare against the restored data to understand what was lost.

Use the [Backup AKS Database workflow](https://github.com/DFE-Digital/find-a-lost-trn/actions/workflows/aks-db-backup.yml) to save a copy of the flawed database. Use a specific name to identify the backup file later on.

### Restore postgres database

First we must restore the database to a new postgres server using the point in time restore (PTR) feature. This will create a new copy of the database as it was at the point in time chosen for the restore, and this copy will be on a new postgres server. The live server will not be affected by this process, and the restored data can be checked and validated before being copied back into the live server.

Run the [Restore database from point in time to new database server workflow](https://github.com/DFE-Digital/find-a-lost-trn/actions/workflows/database-restore-ptr.yml) using a time before the data was deleted. If you need to rerun the workflow, it may fail if the new server was already created. Override the new server name to work around the issue.

| Required Parameter               | Description                                                      | Options                                |
| -------------------------------- | ---------------------------------------------------------------- | -------------------------------------- |
| Environment to restore           | The environment to restore the database server in.               | test, preproduction, production        |
| Confirm production               | A true/false confirmation if running in production.              | true, false                            |
| Restore point in time            | Restore point in time in UTC.<br/>See below for important notes. | e.g. 2024-07-24T06:00:00               |
| Name of the new database server. | The name to be used for the new server.                          | Default is <original-server-name>-ptr. |

**Important:** You should convert the time to UTC before actually using it. When you record the time, note what timezone you are using. Especially during BST (British Summer Time).

### Validate data

It may be necessary to connect to the PTR postgres server for troubleshooting, before deciding on a full restore or otherwise. For instance, the PTR restore may have to be rerun with a different date/time. Konduit allows you to connect to a backend service via an app instance, and can be used to connect to the PTR postgres server to check the data before restoring to the live server. This can be used to check if the restore was successful, and if the correct point in time was chosen for the restore.

The following needs to be done locally within a cloned copy of the repository, and requires `konduit.sh` to be installed locally.

To connect to the PTR postgres copy using `psql` via konduit:

- Install `konduit.sh` locally using the `make` command
- Run: `bin/konduit.sh -x -n <namespace-of-deployment> -s <name-of-ptr-server> <name-of-deployment> -- psql`

e.g. `bin/konduit.sh -x -n tra-test -s <name-of-ptr-server> find-a-lost-trn-test -- psql`

To connect to the existing live postgres server for comparison:

- Run: `bin/konduit.sh -x name-of-deployment -- psql`

e.g. `bin/konduit.sh -x find-a-lost-trn-test -- psql`

### Upload restored database to Azure storage

At this point we have restored the database at the point in time we want to recover onto a new postgres server. We now need to get this data back into the live server. To do that, we first need to back up the restored database to Azure storage so that it can then be used as the source for restoring into the live server.

This step is required even if you completed the optional backup step before restoring the PTR copy, as that backup would have been taken of the corrupted data, whereas this backup will be taken of the restored data.

Use the [Backup AKS Database workflow](https://github.com/DFE-Digital/find-a-lost-trn/actions/workflows/aks-db-backup.yml) workflow and choose the restored server as input. Use a specific name to identify the backup file later on.

### Restore data into the live server

To perform a complete restore of the live server from the PTR copy, use the [Restore database from Azure storage workflow](https://github.com/DFE-Digital/find-a-lost-trn/actions/workflows/database-restore.yml) and choose the backup file created above to restore to the live postgres server.

Note that when entering the backup filename that the name entered in the `Upload restored database to Azure storage` job should be appended with `.sql.gz` so that the file can correctly be looked up.

### Restart applications

e.g. [update namespace and deployment names as required, the below refers to the tra-test environment]

- `kubectl -n tra-test get deployments`
- `kubectl -n tra-test scale deployment find-a-lost-trn-test --replicas 2`
- `kubectl -n tra-test scale deployment find-a-lost-trn-test-worker --replicas 1`

### Validate app

Confirm the app is working and can see the restored data.

You may also want to check any healthcheck urls (e.g. /healthcheck), admin interfaces, api requests, etc

Healthcheck URLs for different environments can be found at:

| Environment   | Healthcheck URL                                             |
| ------------- | ----------------------------------------------------------- |
| production    | https://find-a-lost-trn.education.gov.uk/health/all         |
| preproduction | https://preprod.find-a-lost-trn.education.gov.uk/health/all |
| test          | https://test.find-a-lost-trn.education.gov.uk/health/all    |

### Unfreeze pipeline

Alert developers that merge to main is allowed.

- In github settings, update the Branch protection rules and set required PR approvers back to 1

### Tidy up

If a PTR was run, the database copy server should be deleted. To do this locate the database server in the Azure portal and delete it. Locating the database server can be done by going to the resource group for the environment and looking for a server with the name used when creating the PTR copy. For example, within the test environment navigating to the resource group `s189t01-faltrn-ts-rg` and looking for a server with the name `<original-server-name>-ptr` or the custom name used when creating the PTR copy.

If this document is being followed as part of a DR test, then [complete DR test post scenario steps](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/disaster-recovery-testing.md#post-scenario-steps)

## Post DR review

- Schedule an incident retro meeting with all the stakeholders
- Review the incident and fill in the incident report
- Raise trello cards for any process improvements
