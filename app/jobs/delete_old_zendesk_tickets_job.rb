class DeleteOldZendeskTicketsJob < ApplicationJob
  def perform
    tickets = ZendeskService.find_closed_tickets_from_6_months_ago
    return if tickets.size.zero?
    if tickets.size >= 100
      raise "More than 100 tickets to delete were found in Zendesk. " \
              "The DeleteOldZendeskTicketsJob doesn't handle pagination. " \
              "If you're seeing this, we need to build pagination."
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
