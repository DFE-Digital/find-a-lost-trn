# frozen_string_literal: true
DfE::Analytics.configure do |config|
  config.queue = :analytics
  config.environment = HostingEnvironment.environment_name
  config.azure_federated_auth = ENV.include? "GOOGLE_CLOUD_CREDENTIALS"

  # Airbyte replicates the database, so the gem's own database events stay off
  config.airbyte_enabled = true
  config.database_events_enabled = false

  config.enable_analytics = proc { FeatureFlag.active?(:send_analytics_events) }
end
