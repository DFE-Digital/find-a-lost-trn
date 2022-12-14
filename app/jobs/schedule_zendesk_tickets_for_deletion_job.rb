class ScheduleZendeskTicketsForDeletionJob < ApplicationJob
  sidekiq_options queue: "low"

  MAX_PAGES = 10
  RESULTS_PER_PAGE = 100

  # Goes through all the pages returned by the Zendesk search API, saves
  # ticket metadata as ZendeskDeleteRequests, then schedules a job for each
  # page of 100 tickets to be deleted, staggered at 5 minutes apart to
  # prevent rate limiting.
  def perform
    return unless HostingEnvironment.production?

    tickets = ZendeskService.find_closed_tickets_from_6_months_ago
    return if tickets.count.zero?

    pages_to_fetch = [(tickets.count / RESULTS_PER_PAGE) + 1, MAX_PAGES].min
    (1..pages_to_fetch).each do |page_number|
      tickets.page(page_number).per_page(RESULTS_PER_PAGE)
      tickets.fetch!

      save_metadata(tickets)

      wait = (page_number * 5).minutes
      ids = tickets.map(&:id)
      DeleteOldZendeskTicketsJob.set(wait:).perform_later(ids:)
    end
  end

  private

  def save_metadata(tickets)
    tickets.each do |ticket|
      ZendeskDeleteRequest
        .find_or_initialize_by(ticket_id: ticket.id)
        .from(ticket)
        .save!
    end
  end
end
