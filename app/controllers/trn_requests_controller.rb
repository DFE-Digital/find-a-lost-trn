# frozen_string_literal: true
class TrnRequestsController < ApplicationController
  def create
    @trn_request = TrnRequest.create
    session[:trn_request_id] = @trn_request.id
    redirect_to helpdesk_request_submitted_url
  end
end
