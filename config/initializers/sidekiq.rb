# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }

  config.on(:startup) do
    schedule_file = 'config/schedule.yml'
    Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file)) if File.exist?(schedule_file)
  end
end

Sidekiq.configure_client { |config| config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') } }
