class ZendeskHealthJob < ApplicationJob
  include Rails.application.routes.url_helpers

  def perform
    return unless FeatureFlag.active?(:slack_alerts)

    tickets_created =
      TrnRequest.with_zendesk_ticket.where(checked_at: 24.hours.ago...).count
    return if tickets_created.positive?

    url = root_url(host: ENV.fetch("HOSTING_DOMAIN"))
    SlackClient.create_message(
      "No Zendesk tickets created in the last 24 hours on #{url}",
    )
  end
end
