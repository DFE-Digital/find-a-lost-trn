# frozen_string_literal: true
class DeleteZendeskTicketsAlertJob < ApplicationJob
  include ActionView::Helpers::TextHelper
  include Rails.application.routes.url_helpers

  def perform
    return unless FeatureFlag.active?(:slack_alerts)

    count = ZendeskService.find_closed_tickets_from_6_months_ago.count
    url = support_interface_zendesk_url(host: ENV.fetch("HOSTING_DOMAIN"))
    message =
      "There are #{pluralize(count, "Zendesk ticket")} scheduled for deletion tomorrow. #{url}"
    SlackClient.create_message(message)
  end
end
