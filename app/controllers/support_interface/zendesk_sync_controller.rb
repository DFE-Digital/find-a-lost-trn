# frozen_string_literal: true
module SupportInterface
  class ZendeskSyncController < SupportInterfaceController
    def create
      update_from_zendesk if zendesk_ticket.comments.many?
      redirect_to support_interface_trn_requests_url
    end

    private

    def trn_request
      @trn_request ||= TrnRequest.find(params[:trn_request_id])
    end

    def update_from_zendesk
      trn = zendesk_ticket.comments.last.body.scan(/\*\*(\d+)\*\*/)&.flatten&.first
      trn_request.update(trn:)
      raw_result = DqtApi.find_teacher!(birthdate: trn_request.date_of_birth, trn:)
      trn_request.trn_responses.create(raw_result:)
    end

    def zendesk_ticket
      @zendesk_ticket ||= ZendeskService.find_ticket(trn_request.zendesk_ticket_id)
    end
  end
end
