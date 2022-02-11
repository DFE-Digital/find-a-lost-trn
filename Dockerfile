FROM ruby:3.0.3-alpine
RUN apk add gcc git libc6-compat libc-dev make nodejs sqlite-dev tzdata yarn

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
    SECRET_KEY_BASE=TestKey
RUN RAILS_ENV=production bundle exec rails assets:precompile
CMD bundle exec rails server -b 0.0.0.0
