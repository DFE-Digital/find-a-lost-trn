class DeleteOldZendeskTicketsJob < ApplicationJob
  def perform
    tickets = ZendeskService.find_closed_tickets_from_6_months_ago
    return if tickets.size.zero?

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
