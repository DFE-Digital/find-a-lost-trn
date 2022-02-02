# Find my TRN

A service that allows teachers to find their Teacher Reference Number (TRN).

## Dependencies

- Ruby 3.x
- Node.js 16.x
- Yarn 1.22.x

## How the application works

Find my TRN is a monolithic Rails app built with the GOVUK Design System and hosted on
GOVUK PaaS.

We keep track of architecture decisions in [Architecture Decision Records
(ADRs)](/adr/).

We use `rladr` to generate the boilerplate for new records:

```bash
bundle exec rladr new title
```

## Setup

Install dependencies using your preferred method, using `asdf` or `rbenv` or `nvm`. Example with `asdf`:

```bash
# The first time
brew install asdf # Mac-specific
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add yarn

# To install (or update, following a change to .tool-versions)
asdf install
```

Setup the project (re-run after `Gemfile` or `package.json` updates, automatically restarts any running Rails server):

```bash
bin/setup
```

Run the application on `http://localhost:3000`:

```bash
bin/dev
```

To run the linters:

```bash
bin/lint
```

To run the tests (requires Chrome due to
[cuprite](https://github.com/rubycdp/cuprite)):

```bash
bin/test
```

## Licence

[MIT Licence](LICENCE).
