class CreateZendeskTicketJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound
  sidekiq_options queue: "critical"

  def perform(trn_request_id)
    trn_request = TrnRequest.find(trn_request_id)
    return if trn_request.zendesk_ticket_id

    ZendeskService.create_ticket!(trn_request)
    TeacherMailer.information_received(trn_request).deliver_later
    CheckZendeskTicketForTrnJob.set(wait: 2.days).perform_later(trn_request.id)
  end
end
