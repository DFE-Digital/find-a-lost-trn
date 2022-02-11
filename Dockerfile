FROM ruby:3.0.3-alpine
RUN apk add gcc git libc6-compat libc-dev make nodejs postgresql13-dev sqlite-dev tzdata yarn

WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN gem update --system
RUN bundle install
RUN gem install nokogiri --platform=ruby
COPY package.json /myapp/package.json
COPY yarn.lock /myapp/yarn.lock
RUN yarn
ADD . /myapp

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
