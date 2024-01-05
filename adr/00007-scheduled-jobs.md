# 7. Scheduled Jobs

Date: 2022-05-03

## Status

Accepted

## Context

This service will need to run jobs on a schedule. We need a way to run domain logic code outside the context of web requests, reliably and in a proactive/scheduled way.

### Findings

We have considered:

- run jobs via the infrastructure (use sidekiq/sidekiq_cron)
- clockwork gem on its own

Considering the effort to deploy and maintain the infrastructure to run the jobs, we think it's better to use sidekiq/sidekiq_cron.

#### Pros

- The sidekiq/sidekiq_cron combination is a proven, stable and scalable combination which can take us all the way to public launch and beyond.
- Code scheduling and organisation will be transparent, as the schedule is defined within the source code of the app and calls standard Rails workers and services. This also gives us an update path for schedules and background tasks, re-using the standard deployment pipelines, as well as auditing information through git version control.
- Because background processing will be handled by Sidekiq, failed jobs can be retried automatically.

#### Cons

- Requires support for multiple containers/services (web/worker) and a Redis instance.

## Decision

We will add the following capabilities to the app:

#### Scheduling

This will be achieved via the `sidekiq_cron` gem. It alllows periodic jobs to be defined in a YAML file within the main Rails app. For example:

```ruby
# config/schedule.yml

performance_report:
  cron: '0 9 * * MON'
```

Sidekiq_cron hooks into the existing Sidekiq setup and will run the jobs defined in the schedule file.

#### Background processing

We will use the existing `sidekiq` gem, which is the current standard for Rails background processing.

Jobs are usually placed within `app/jobs` and can call any other classes within the Rails app, such as service objects to achieve their goals.

## Consequences

No additional work will be required on Azure to run the scheduled jobs.
