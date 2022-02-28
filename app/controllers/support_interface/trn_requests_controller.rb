# frozen_string_literal: true
module SupportInterface
  class TrnRequestsController < SupportInterfaceController
    def index
      @trn_requests = TrnRequest.all
    end
  end
end
