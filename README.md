# Find a lost TRN

A service that allows teachers to find their Teacher Reference Number (TRN).

## Live environments

| Name       | URL                                                               | Description                                                           | PaaS space       | PaaS application             |
| ---------- | ----------------------------------------------------------------- | --------------------------------------------------------------------- | ---------------- | ---------------------------- |
| Production | [production](https://find-a-lost-trn.education.gov.uk/start)      | Public site                                                           | `tra-production` | `find-a-lost-trn-production` |
| Preprod    | [preprod](https://preprod-find-a-lost-trn.education.gov.uk/start) | For internal use by DfE to test deploys                               | `tra-test`       | `find-a-lost-trn-preprod`    |
| Test       | [test](https://test-find-a-lost-trn.education.gov.uk/start)       | Demo environment for software vendors who integrate with our API      | `tra-test`       | `find-a-lost-trn-test`       |
| Dev        | [dev](https://dev-find-a-lost-trn.education.gov.uk/start)         | For internal use by DfE for testing. Automatically deployed from main | `tra-dev`        | `find-a-lost-trn-dev`        |

Gotchas:

- Dev uses a `test` Notify key so it doesn't send real emails. You have to
  check the API integration section of Notify to see them.
- Dev uses the `preprod` deployment of the `qualified-teachers-api` which
  should allow us to find the TRN of anonymised users.
- All other environments use production Notify and the production
  `qualified-teachers-api`.

## Dependencies

- Ruby 3.x
- Node.js 16.x
- Yarn 1.22.x
- PostgreSQL 13.x
- Redis 6.x

## How the application works

Find a lost TRN is a monolithic Rails app built with the GOVUK Design System and hosted on
GOVUK PaaS.

We keep track of architecture decisions in [Architecture Decision Records
(ADRs)](/adr/).

We use `rladr` to generate the boilerplate for new records:

```bash
bin/bundle exec rladr new title
```

## Setup

### Bare metal

Install dependencies using your preferred method, using `asdf` or `rbenv` or `nvm`. Example with `asdf`:

```bash
# The first time
brew install asdf # Mac-specific
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add yarn
asdf plugin add postgres
asdf plugin add redis

# To install (or update, following a change to .tool-versions)
asdf install
```

If installing PostgreSQL via `asdf`, set up the `postgres` user:

```bash
pg_ctl start
createdb default
psql -d default
> CREATE ROLE postgres LOGIN SUPERUSER;
```

You might also need to install `postgresql-libs`:

```bash
sudo apt install libpq-dev
sudo yum install postgresql-devel
sudo zypper in postgresql-devel
sudo pacman -S postgresql-libs
```

If installing Redis, you'll need to start it in a separate terminal:

```bash
redis-server
```

Setup the project (re-run after `Gemfile` or `package.json` updates, automatically restarts any running Rails server):

```bash
bin/setup
```

Run the application on `http://localhost:3000`:

```bash
bin/dev
```

### Notify

If you want to test and simulate sending emails locally, you need to be added
to the TRA digital Notify account. Then, go to
`API integration > API keys > Create an API key` and create a new key, such as
`Myname - local test` and set the type to `Test - pretends to send messages`.

Add this key to your local development secrets:

```bash
$ vim .env.development.local
GOVUK_NOTIFY_API_KEY=theo__local_test-abcefgh-1234-abcdefgh
```

When you send an email locally, the email should appear in the message log in
the Notify dashboard in the `API integration` section.

### Docker

To run the application locally in production mode (to test that the container
builds and runs successfully):

```bash
docker build .
docker run --net=host --env-file .env.development <SHA>
```

### Linting

To run the linters:

```bash
bin/lint
```

### Testing

To run the tests (requires Chrome due to
[cuprite](https://github.com/rubycdp/cuprite)):

```bash
bin/test
```

### Ops manual

[OPS manual](docs/ops-manual.md).

## Licence

[MIT Licence](LICENCE).
