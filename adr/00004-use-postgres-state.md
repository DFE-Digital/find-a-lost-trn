# 4. Use postgres to handle persistence

Date: 2022-02-02

## Status

Accepted

## Context

We need a persistence device to store application state, that is in-line with our rails architecture and standard service design within the DfE.

## Decision

We have decided to use Postgres to store session state

## Consequences

- Ease of development with activerecord in the Rails framework.
- Application is inline with standard DfE approach to use session state.
