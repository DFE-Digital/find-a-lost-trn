# frozen_string_literal: true
module SupportInterface
  class TrnRequestsController < SupportInterfaceController
    def index
      @trn_requests = TrnRequest.order(updated_at: :desc).limit(100)
      @export_form = SupportInterface::TrnRequestExportForm.new
    end
  end
end
