# Find a lost TRN ops manual

## SSHing to a live docker container

To SSH into a container, install the `cloudfoundry-cli`. Example using `asdf`:

```bash
$ asdf plugin add cf
$ asdf cf install latest
$ asdf global cf latest
$ cf --version
cf version 8.3.0+e6f8a85.2022-03-11
```

You'll need a PaaS account that has access to the
`tra-dev/tra-test/tra-production` space. Sign into your account using SSO:

```bash
$ cf login -a api.london.cloud.service.gov.uk --sso
API endpoint: api.london.cloud.service.gov.uk

Temporary Authentication Code ( Get one at https://login.london.cloud.service.gov.uk/passcode ):
Authenticating...
OK


Targeted org dfe.

Select a space:
1. sandbox
2. tra-dev
3. tra-production
4. tra-test

Space (enter to skip): 2
Targeted space tra-dev.

API endpoint:   https://api.london.cloud.service.gov.uk
API version:    3.112.0
user:           1XXXXXXXXXXXXXXXXXXXX
org:            dfe
space:          tra-dev
```

To SSH into the running docker container and go to the app directory:

```bash
$ cf ssh find-a-lost-trn-dev
$ cd /app
```

**Note**: SSH access is monitored and logged as an event in the Events tab on
the PaaS website.

## Tailing logs

SSH into the machine and run:

```bash
$ tail -f /app/log/production.log
```
