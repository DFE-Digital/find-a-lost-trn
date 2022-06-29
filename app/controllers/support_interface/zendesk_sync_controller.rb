# frozen_string_literal: true
module SupportInterface
  class ZendeskSyncController < SupportInterfaceController
    def create
      trn_request = TrnRequest.find(params[:trn_request_id])
      flash[:warning] = t(".warning") unless FetchTrnFromZendesk.new(
        trn_request:
      ).call
      redirect_to support_interface_trn_requests_url
    end
  end
end
