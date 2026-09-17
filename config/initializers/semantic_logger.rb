return unless defined?(SemanticLogger)

Rails.application.configure do
  config.semantic_logger.application = "" # This is added by logstash from its tags
  config.log_tags = [:request_id]         # Prepend all log lines with the following tags
end

# on_log sees each entry before any appender formats it, so this also covers the
# stdout appender the gem adds in the Sidekiq server, and scrubs strings before
# JSON escapes them. After boot, so every initializer's filter_parameters count.
Rails.application.config.after_initialize do
  # The fields the mailer subscriber logs on every delivery, plus args, which is
  # also where the Sidekiq error handler keeps a failed job's arguments.
  # Anchored, so :to does not match "photo".
  sensitive_fields = /\A(subject|to|from|cc|bcc|args)\z/i
  # message_id is email-shaped but ties a delivery to its failure. ParameterFilter
  # hands over a copy and ignores the return value, hence replace.
  scrub_addresses = lambda do |key, value|
    value.replace(Logstop.scrub(value)) if value.is_a?(String) && key.to_s != "message_id"
  end
  filter = ActiveSupport::ParameterFilter.new(
    Rails.application.config.filter_parameters + [sensitive_fields, scrub_addresses],
  )
  # Copies, so whatever rescued the original still sees its real message. dup
  # first: copying a frozen exception raises an error quoting the original text.
  # The copy's cause, and any to_s override (zendesk_api's errors have one), still
  # read the original, hence the replacement methods.
  scrub_exception = lambda do |exception|
    cause = exception.cause && scrub_exception.call(exception.cause)
    message = Logstop.scrub(exception.message)
    exception.dup.exception(message).tap do |copy|
      copy.define_singleton_method(:message) { message }
      copy.define_singleton_method(:to_s) { message }
      copy.define_singleton_method(:cause) { cause }
    end
  end

  SemanticLogger.on_log do |log|
    log.payload = filter.filter(log.payload) if log.payload.is_a?(Hash)
    log.message = Logstop.scrub(log.message) if log.message
    log.exception = scrub_exception.call(log.exception) if log.exception
  rescue StandardError => e
    # The gem would otherwise write the entry unredacted, so withhold it and
    # record the failure in its place, at error level so it stands out in Logit
    log.message = "Log entry withheld: redaction failed"
    log.payload = nil
    log.exception = e
    log.level = :error
    log.level_index = SemanticLogger::Levels.index(:error)
  end
end

return unless Rails.env.production? # Logit reads stdout; specs attach their own appenders

SemanticLogger.add_appender(io: $stdout, level: Rails.application.config.log_level, 
formatter: Rails.application.config.log_format)
Rails.application.config.logger.info('Application logging to STDOUT')
