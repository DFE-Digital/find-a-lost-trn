# 5. Use automated tooling to check for CVEs in dependant packages

Date: 2022-02-02

## Status

Accepted

## Context

As part of the threat modelling exercise undertaken during this project, a threat was identified regarding CVEs within dependent libraries. (Risk#5 - Known Vulnerabilities)

As a mitigation for this threat, we need an automated way of checking for issues in libraries.

## Decision

We have decided to use Dependabot and/or Gemsurance in our build pipelines to check for CVEs, which will act as a mitigation for the identified risk.

## Consequences

* Libraries will be scanned during the build pipeline
* Automated builds may be interrupted if a CVE is found, potentially stopping a release from proceeding.
