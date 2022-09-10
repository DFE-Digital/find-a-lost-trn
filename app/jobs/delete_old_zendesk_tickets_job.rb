class DeleteOldZendeskTicketsJob < ApplicationJob
  def perform
    return unless HostingEnvironment.environment_name == "production"

    tickets = ZendeskService.find_closed_tickets_from_6_months_ago
    return if tickets.count.zero?
    if tickets.count >= 100
      DeleteOldZendeskTicketsJob.set(wait: 5.minutes).perform_later
    end

    tickets.each do |ticket|
      ZendeskDeleteRequest
        .find_or_initialize_by(ticket_id: ticket.id)
        .from(ticket)
        .save!
    end

    ids = tickets.map(&:id)
    ZendeskService.destroy_tickets!(ids)
  end
end
