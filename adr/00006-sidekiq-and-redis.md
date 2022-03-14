# 6. Sidekiq and Redis

Date: 2022-03-14

## Status

Accepted

## Context

We need a background job system to allow us to retry tasks like querying the
DQT API or submitting a Zendesk ticket on behalf of the user.

## Decision

Use the Sidekiq + Rails combination which is in wide use in Teacher Services.

## Consequences

- We introduce a new service for developing locally
- Our deployment environments need to manage deploying a Redis instance as well
