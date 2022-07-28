FROM ruby:3.1.1-alpine

RUN apk -U upgrade && \
    apk add --update --no-cache gcc git libc6-compat libc-dev make nodejs \
    postgresql13-dev tzdata yarn

RUN echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

ENV GOVUK_NOTIFY_API_KEY=TestKey \
    LANG=en_GB.UTF-8 \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=yes \
    REDIS_URL=redis://required-but-not-used \
    SECRET_KEY_BASE=TestKey \
    ZENDESK_TOKEN=TestToken \
    ZENDESK_USER=TestUser

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem update --system && \
    bundler -v && \
    bundle config set no-cache 'true' && \
    bundle config set no-binstubs 'true' && \
    bundle install --retry=5 --jobs=4 --without=development && \
    rm -rf /usr/local/bundle/cache

COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile --check-files

COPY . .

RUN bundle exec rails assets:precompile && \
    rm -rf tmp/* log/* node_modules /tmp/*

CMD bundle exec rails db:migrate:ignore_concurrent_migration_exceptions && \
    bundle exec rails data:migrate && \
    bundle exec rails server -b 0.0.0.0
