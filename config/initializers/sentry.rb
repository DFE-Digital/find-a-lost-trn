# frozen_string_literal: true
Sentry.init do |config|
  config.environment = HostingEnvironment.environment_name
  env_var_filters = Regexp.union(ENV.values)
  filter =
    ActiveSupport::ParameterFilter.new(
      Rails.application.config.filter_parameters +
        [
          ->(k, v) do
            return unless k == "value" && k == "title"
            v.gsub!(env_var_filters, "[FILTERED]") if env_var_filters.match?(v)
          end
        ]
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
