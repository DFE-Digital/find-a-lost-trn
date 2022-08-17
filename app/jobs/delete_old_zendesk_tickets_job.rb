class DeleteOldZendeskTicketsJob < ApplicationJob
  def perform
    tickets = ZendeskService.find_closed_tickets_from_6_months_ago
    return if tickets.size.zero?

    ids = tickets.map(&:id)
    ZendeskService.destroy_tickets!(ids)
  end
end
