# Find a lost TRN

A service that allows teachers to find their Teacher Reference Number (TRN).

## Dependencies

- Ruby 3.x
- Node.js 16.x
- Yarn 1.22.x
- PostgreSQL 13.x

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

Setup the project (re-run after `Gemfile` or `package.json` updates, automatically restarts any running Rails server):

```bash
bin/setup
```

Run the application on `http://localhost:3000`:

```bash
bin/dev
```

### Docker

**NOTE:** Currently out of date, because `Dockerfile` is being used for the
production deployment.

If you prefer to run the application in a Docker container, then you can use the following commands:

```bash
bin/docker
```

This uses Docker Compose to co-ordinate all the services required to run the application.

After running this for the first time, you can run the application setup using:

```bash
bin/setup
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
