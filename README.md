# Find a lost TRN

A service that allows teachers to find their Teacher Reference Number (TRN).

## Live environments

### Links and application names

| Name          | URL (Frontdoor)                                  | Deployment | AKS namespace     | Ingress URL                                                      |
| ------------- | ------------------------------------------------ | ---------- | ----------------- | ---------------------------------------------------------------- |
| Production    | https://find-a-lost-trn.education.gov.uk         | Automatic  | `tra-production`  | https://find-a-lost-trn-production.teacherservices.cloud         |
| Preproduction | https://preprod.find-a-lost-trn.education.gov.uk | Automatic  | `tra-test`        | https://find-a-lost-trn-preproduction.test.teacherservices.cloud |
| Test          | https://test.find-a-lost-trn.education.gov.uk    | Automatic  | `tra-test`        | http://find-a-lost-trn-test.test.teacherservices.cloud           |
| Dev           | https://dev.find-a-lost-trn.education.gov.uk     | Automatic  | `tra-development` | https://find-a-lost-trn-development.test.teacherservices.cloud   |

All environments have continuous deployment, the state of which can be inspected in Github Actions.

### Details and configuration

| Name       | Description                                   | Zendesk | Notify   | `qualified-teachers-api` | Identity   |
| ---------- | --------------------------------------------- | ------- | -------- | ------------------------ | ---------- |
| Production | Public site                                   | Live    | Live key | Production               | Production |
| Preprod    | For internal use by DfE to test deploys       | Live    | Live key | Production               | Production |
| Test       | For external use by 3rd parties to run audits | Stubbed | Live key | Preprod                  | Preprod    |
| Dev        | For internal use by DfE for testing           | Stubbed | Test key | Preprod                  | Preprod    |

Gotchas:

- Dev uses a `test` Notify key so it doesn't send real emails. You have to
  check the API integration section of Notify to see them.
- Dev uses the `preprod` deployment of the `qualified-teachers-api` which
  allows us to find the TRNs of test users.

### Test users

You can use this user to test that matching works against the preprod
`qualified-teachers-api` (for example, on `find-a-lost-trn-dev`):

| Field                     | Value                 |
| ------------------------- | --------------------- |
| Email                     | `kevin.e@example.com` |
| First name                | `Kevin`               |
| Last name                 | `E`                   |
| Date of birth             | `1 1 1990`            |
| National insurance number | `AA123456A`           |

## Dependencies

- Ruby 3.x
- Node.js 16.x
- Yarn 1.22.x
- PostgreSQL 13.x
- Redis 6.x

## Local development dependencies

- Graphviz 2.22+ (brew install graphviz) to generate the [domain model diagram](#domain-model)

## How the application works

Find a lost TRN is a monolithic Rails app built with the GOVUK Design System and hosted on
GOVUK AKS.

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
asdf plugin add azure-cli
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add yarn
asdf plugin add postgres
asdf plugin add redis

# To install (or update, following a change to .tool-versions)
asdf install
```

If installing PostgreSQL via `asdf`, you may need to set up the `postgres` user:

```bash
pg_ctl start
createdb default
psql -d default
> CREATE ROLE postgres LOGIN SUPERUSER;
```

If the install step created the `postgres` user already, it won't have created one
matching your username, and you'll see errors like:

`FATAL: role "username" does not exist`

So instead run:

```bash
pg_ctl start
createdb -U postgres default
```

You might also need to install `postgresql-libs`:

```bash
sudo apt install libpq-dev
sudo pacman -S postgresql-libs
sudo pamac install postgres-libs
sudo yum install postgresql-devel
sudo zypper in postgresql-devel
```

If installing Redis, you'll need to start it in a separate terminal:

```bash
redis-server
```

Setup the project (re-run after `Gemfile` or `package.json` updates, automatically restarts any running Rails server):

```bash
bin/setup
```

Follow the instructions in [docs/encryption.md](docs/encryption.md)
to correctly set up database encryption.

Run the application on `http://localhost:3000`:

```bash
bin/dev
```

### Authentication

Due to the `Service open` feature flag which is set to `false` by default across all environments except Production, you will be asked to sign in with basic auth. You can find credentials in the .env._environment_ file stored in the ENV variables `SUPPORT_USERNAME` and `SUPPORT_PASSWORD`. You can toggle the `Service open` feature flag to `true` when developing locally to switch off basic auth.

The support interface for this service sits behind an auth system detailed [here](docs/staff-authentication.md).

### Notify

Notify emails are printed in `tail -f log/development.log` in local dev.

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

To compile assets up front (needed by the end to end tests):

```bash
bin/rails assets:precompile
```

To run the tests (requires Chrome due to
[cuprite](https://github.com/rubycdp/cuprite)):

```bash
bin/test
```

### Intellisense

[solargraph](https://github.com/castwide/solargraph) is bundled as part of the
development dependencies. You need to [set it up for your
editor](https://github.com/castwide/solargraph#using-solargraph), and then run
this command to index your local bundle (re-run if/when we install new
dependencies and you want completion):

```sh
bin/bundle exec yard gems
```

You'll also need to configure your editor's `solargraph` plugin to
`useBundler`:

```diff
+  "solargraph.useBundler": true,
```

### Domain model

![The domain model for this application](docs/domain-model.png)

Regenerate this diagram with `bundle exec rake erd`.

### Ops manual

[OPS manual](docs/ops-manual.md).

## Licence

[MIT Licence](LICENCE).
