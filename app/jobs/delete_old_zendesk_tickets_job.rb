class DeleteOldZendeskTicketsJob < ApplicationJob
  sidekiq_options queue: "low"

  def perform(ids:)
    return unless HostingEnvironment.production?

    ZendeskService.destroy_tickets!(ids)
  end
end
