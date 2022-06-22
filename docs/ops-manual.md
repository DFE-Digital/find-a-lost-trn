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

## Running a Rails console

SSH into the machine and run:

```bash
$ /usr/local/bin/bundle exec rails console
```

## Tailing logs

SSH into the machine and run:

```bash
$ tail -f /app/log/production.log
```

## Logit

You can raise a request to #digital-tools-support on Slack filling the [Digital Tools Request Form](https://docs.google.com/forms/d/e/1FAIpQLSe8pAACWb8FUH0qXpUsoUoa6w1GuRvSNour-lHliGPaJ7u73A/viewform) to be added to Teaching Regulation Agency (TRA) stack. Follow the **Logit** section of [the TRA resources Google document](https://docs.google.com/document/d/1A6TMWkFYc_q2IQLh5KhRSPOr91e_l9lxI_tFtZ8tdxc/edit#heading=h.8atf3at2he6o)document to help you fill the form. You can sign in once your email is added to the Logit stack.
