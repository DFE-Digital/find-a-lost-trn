# frozen_string_literal: true
module SupportInterface
  class ZendeskSyncController < SupportInterfaceController
    def create
      update_from_zendesk if zendesk_ticket.comments.many?
      redirect_to support_interface_trn_requests_url
    end

    private

    def trn
      @trn ||= zendesk_ticket.comments.last.body.scan(/\*\*(\d{7})\*\*/).flatten.first
    end

    def trn_request
      @trn_request ||= TrnRequest.find(params[:trn_request_id])
    end

    def update_from_zendesk
      return if trn.blank?

      raw_result = DqtApi.find_teacher!(date_of_birth: trn_request.date_of_birth, trn: trn)
      trn_request.trn_responses.create(raw_result: raw_result)
      trn_request.update(trn: raw_result['trn'])
    end

    def zendesk_ticket
      @zendesk_ticket ||= ZendeskService.find_ticket(trn_request.zendesk_ticket_id)
    end
  end
end
