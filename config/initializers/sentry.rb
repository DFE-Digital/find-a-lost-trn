# frozen_string_literal: true
Sentry.init do |config|
  config.environment = HostingEnvironment.environment_name
  rails_filter_parameters =
    Rails.application.config.filter_parameters.map(&:to_s)
  env_variables =
    ENV.select do |k, _v|
      rails_filter_parameters.any? do |parameter|
        k.downcase.include?(parameter)
      end
    end
  env_values = Regexp.union(env_variables.values)
  env_filter = ->(k, v) do
    return unless %i[value title].include?(k)
    v.gsub!(env_values, "[FILTERED]") if env_values.match?(v)
  end
  filter =
    ActiveSupport::ParameterFilter.new(
      Rails.application.config.filter_parameters + [env_filter]
    )

  config.before_send = lambda { |event, _hint| filter.filter(event.to_hash) }

  config.inspect_exception_causes_for_exclusion = true

  config.excluded_exceptions += [
    # The following exceptions are user-errors that aren't actionable, and can
    # be safely ignored.
    "ActionController::BadRequest",
    "ActionController::UnknownFormat",
    "ActionController::UnknownHttpMethod",
    "ActionDispatch::Http::Parameters::ParseError",
    "Mime::Type::InvalidMimeType"
  ]
end
