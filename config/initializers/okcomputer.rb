OkComputer.logger = Rails.logger
OkComputer.mount_at = "health"

OkComputer::Registry.register "postgresql", OkComputer::ActiveRecordCheck.new

Sidekiq.redis do |conn|
  OkComputer::Registry.register "sidekiq",
                                OkComputer::RedisCheck.new(conn.connection)
  OkComputer::Registry.register "sidekiq-latency",
                                OkComputer::SidekiqLatencyCheck.new("default")
end

OkComputer::Registry.register "version", OkComputer::AppVersionCheck.new

OkComputer.make_optional %w[version]
