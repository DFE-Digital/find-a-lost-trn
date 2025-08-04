FROM ruby:3.4.4-alpine

RUN apk -U upgrade && \
    apk add --update --no-cache gcc git libc6-compat libc-dev make nodejs \
    postgresql13-dev tzdata yarn g++

RUN echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

# Create non-root user and group with specific UIDs/GIDs
RUN addgroup -S appgroup -g 20001 && adduser -S appuser -G appgroup -u 10001

ENV GOVUK_NOTIFY_API_KEY=TestKey \
    HOSTING_DOMAIN=https://required-but-not-used \
    LANG=en_GB.UTF-8 \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=yes \
    REDIS_URL=redis://required-but-not-used \
    SECRET_KEY_BASE=TestKey \
    ZENDESK_TOKEN=TestToken \
    ZENDESK_URL=https://required-but-not-used \
    ZENDESK_USER=TestUser \
    IDENTITY_SHARED_SECRET_KEY=testkey \
    IDENTITY_API_URL=http://localhost \
    IDENTITY_API_KEY=TestKey

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

# Change ownership only for directories that need write access

RUN chown appuser:appgroup /app/tmp

# Switch to non-root user
USER 10001

CMD bundle exec rails db:migrate:ignore_concurrent_migration_exceptions && \
    bundle exec rails data:migrate:ignore_concurrent_migration_exceptions && \
    bundle exec rails server -b 0.0.0.0
