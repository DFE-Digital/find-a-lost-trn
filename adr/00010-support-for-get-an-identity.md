# 10. Support for Get an Identity

Date: 2022-09-08

## Status

Accepted

## Context

Get an Identity needs an interface to allow support users to link Get an
Identity records to DQT records.

A separate microservice frontend was considered, but the monolithic approach of
integrating it into Find was preferred. This allows us to skip "Sprint 0" work
and benefit from the existing testing, deployment, and ops infrastructure
present in Find.

Designs:

- https://tra-digital-design-history.herokuapp.com/get-an-identity/support-link-dqt/
- https://tra-digital-design-history.herokuapp.com/get-an-identity/support-screen-concepts/

## Decision

"Support for Get an Identity" will be a section in Find's support, and will
communicate with both Get an Identity and the `qualified-teachers-api`.

It will communicate with Get an Identity to:

- List users
- Verify user's names
- Link an Identity record with a DQT record

It will communicate with `qualified-teachers-api` to:

- Look up DQT records by a TRN

The support section is "mostly stateless." The records exist in the Identity
server and Find is just acting as a thin frontend to display and manage them in
a user friendly way.

### Consequences

- Get an Identity will expose RESTful endpoints for user data
- Find will integrate with Get an Identity's authentication system for
  accessing and managing sensitive user data
  - Staff/Admin user records in Find need to be matched/associated/created in
    Get an Identity
