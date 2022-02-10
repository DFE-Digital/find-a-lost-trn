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
ENV RAILS_ENV=development \
    DOCKER_BUILDKIT=1
RUN --mount=type=secret,id=test \
    test="$(cat /run/secrets/test)" \
    echo ${test}
    export test
ENV TEST=${test}
RUN echo $TEST
RUN RAILS_ENV=development bundle exec rails assets:precompile
CMD bundle exec rails server -b 0.0.0.0




# FROM ruby:3.0.3-alpine
# RUN apk add gcc git libc6-compat libc-dev make nodejs sqlite-dev tzdata yarn
# # throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1

# WORKDIR /usr/src/app
# RUN gem update --system
# RUN bundle config unset frozen
# COPY Gemfile Gemfile.lock package.json yarn.lock ./
# RUN bundle config unset frozen
# RUN bundle update sassc
# RUN bundle install
# RUN gem install nokogiri --platform=ruby
# RUN yarn
# CMD yarn build
# CMD yarn build:css
# COPY . .
# CMD bundle exec rails server -b 0.0.0.0
# EXPOSE 3000


