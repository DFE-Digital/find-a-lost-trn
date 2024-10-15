# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"
require "active_support/parameter_filter"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require "./app/lib/hosting_environment"

module FindALostTrn
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.active_job.queue_adapter = :sidekiq

    config.active_record.encryption.store_key_references = true

    config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets/images")
    config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets/fonts")

    config.exceptions_app = routes
    config.console1984.ask_for_username_if_empty = true
    config.audits1984.auditor_class = "Staff"
    config.audits1984.base_controller_class =
      "SupportInterface::SupportInterfaceController"

    config.credentials.content_path =
      (
        if HostingEnvironment.test_environment?
          "config/credentials.yml.enc"
        else
          "config/credentials/production.yml.enc"
        end
      )
  end
end
