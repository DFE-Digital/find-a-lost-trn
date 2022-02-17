FROM ruby:3.0.3-alpine
RUN apk add gcc git libc6-compat libc-dev make nodejs postgresql13-dev sqlite-dev tzdata yarn

WORKDIR /myapp

COPY Gemfile /myapp/
COPY Gemfile.lock /myapp/
RUN gem update --system
RUN bundle install

COPY package.json /myapp/
COPY yarn.lock /myapp/
RUN yarn install --frozen-lockfile

ADD . /myapp
ENV RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=yes \
    LANG=en_GB.UTF-8 \
    SECRET_KEY_BASE=TestKey

RUN yarn build && yarn build:css
RUN bundle exec rails assets:precompile

CMD bundle exec rails db:migrate:ignore_concurrent_migration_exceptions && \
    bundle exec rails server -b 0.0.0.0
