# frozen_string_literal: true
class PerformanceAlertJob < ApplicationJob
  include ActionView::Helpers::TextHelper
  include Rails.application.routes.url_helpers

  def perform
    count =
      TrnRequest.where(
        created_at: 1.week.ago.beginning_of_day..Time.zone.now
      ).count
    url = performance_url(host: ENV.fetch("HOSTING_DOMAIN"))
    message =
      "There have been #{pluralize(count, "TRN request")} started in the last 7 days on #{url}"
    SlackClient.create_message(message)
  end
end
