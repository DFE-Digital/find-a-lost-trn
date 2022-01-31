# Find My TRN

A service that allows teachers to find their Teacher Reference Number (TRN).

## Dependencies

- Ruby 3.x
- Node.js 16.x
- Yarn 1.22.x

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

## Licence

[MIT Licence](LICENCE).

