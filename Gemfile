# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.1"

gem "bootsnap", require: false
gem "cssbundling-rails"
gem "faraday", "~> 1.10"
gem "gds_zendesk"
gem "govuk-components", "~> 3.1.3"
gem "govuk_design_system_formbuilder"
gem "govuk_markdown", "~> 1.0"
gem "jsbundling-rails"
gem "logstop", "~> 0.2.8"
gem "mail-notify"
gem "okcomputer", "~> 1.18"
gem "pg", "~> 1.3"
gem "puma", "~> 5.6"
gem "rack-attack"
gem "rails", "~> 7.0.3"
gem "sentry-rails"
gem "sidekiq"
gem "sidekiq-cron", "~> 1.6"
gem "sprockets-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "factory_bot_rails"
end

group :development do
  gem "foreman", "~> 0.87.2"
  gem "rladr", "~> 1.2"
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem "spring"
  gem "spring-commands-rspec"

  gem "annotate", require: false
  gem "prettier_print", "~> 0.1.0", require: false
  gem "rubocop-govuk", require: false
  gem "solargraph", require: false
  gem "solargraph-rails", require: false
  gem "syntax_tree", "~> 2.7", require: false
  gem "syntax_tree-haml", "~> 1.2", require: false
  gem "syntax_tree-rbs", "~> 0.4.0", require: false

  gem "rails-erd"
end

group :test do
  gem "capybara", "~> 3.36"
  gem "capybara-email"
  gem "cuprite", "~> 0.13"
  gem "faker"
  gem "rspec"
  gem "rspec-rails"
  gem "shoulda-matchers", "~> 5.1"
  gem "timecop"
  gem "vcr", "~> 6.1"
  gem "webmock", "~> 3.14"
end
