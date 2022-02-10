FROM ruby:3.0.3-alpine
RUN apk add gcc git libc6-compat libc-dev make nodejs sqlite-dev tzdata yarn

WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN gem update --system
RUN bundle install
RUN gem install nokogiri --platform=ruby
COPY package.json /myapp/package.json
COPY yarn.lock /myapp/yarn.lock
RUN yarn
CMD yarn build
CMD yarn build:css
ADD . /myapp

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
CMD bundle exec rails server -b 0.0.0.0
EXPOSE 3000



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


