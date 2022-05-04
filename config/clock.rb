# frozen_string_literal: true
require './config/boot'
require './config/environment'
require 'clockwork'

class Clock
  include Clockwork

  configure { |config| config[:tz] = 'Europe/London' }
  error_handler { |error| Sentry.capture_exception(error) if defined?(Sentry) }

  every(1.week, 'performance.alert', at: 'Monday 09:00') { PerformanceAlertJob.perform_later }
end
