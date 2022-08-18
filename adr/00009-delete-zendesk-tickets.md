# 9. Delete Zendesk tickets

Date: 2022-08-16

## Status

Accepted

## Context

We need to delete Zendesk tickets that are 6 months or older due to our data
retention policy. Some of these Zendesk tickets are created by Find, and others
are created through other means.

Find is in a good position to handle deleting tickets, because it already
communicates with the Zendesk API and can provide interfaces and jobs to handle
this task.

We need to delete:

- Tickets
- That are older than 6 months
- That are in a `Closed` state

When deleting, we need to retain certain fields for reporting purposes:

- Ticket id: `.id`
- Received date: `.created_at`
- Closed date: `.updated_at`
- Enquiry type (Custom field): `.custom_fields.find { |cf| cf.id == 4419328659089 }.value`
- No action required (Custom field): `.custom_fields.find { |cf| cf.id == 4562126876049 }.value`
- Group name: `.group.name` (NB: Querying for this is an extra HTTP request)

## Decision

Find will use a background job to delete closed tickets that have not been
updated in 6 months or more.

Find will retain `ZendeskDeleteRequest` as rows in the database containing the
necessary metadata and allow exporting / reporting of useful data.

## Consequences

- Find becomes an essential part of our data retention policy in a way that
  isn't immediately obvious
- We can't change our minds later about what fields we should retain
