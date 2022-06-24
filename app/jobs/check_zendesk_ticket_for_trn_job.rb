# frozen_string_literal: true
class CheckZendeskTicketForTrnJob < ApplicationJob
  def perform(trn_request_id)
    trn_request = TrnRequest.find(trn_request_id)
    return if FetchTrnFromZendesk.new(trn_request: trn_request).call

    ticket = GDS_ZENDESK_CLIENT.ticket.find(id: trn_request.zendesk_ticket_id)
    return if %w[closed solved].include?(ticket.status)

    CheckZendeskTicketForTrnJob.set(wait: 1.day).perform_later(trn_request.id)
  end
end
