# frozen_string_literal: true
class TrnRequestsController < ApplicationController
  def show
    redirect_to root_url unless trn_request
    session[:form_complete] = true
  end

  def update
    redirect_to root_url unless trn_request
    session[:form_complete] = false

    trn_request.update(trn_request_params)
    ZendeskService.create_ticket!(trn_request)
    redirect_to helpdesk_request_submitted_url
  end

  private

  def trn_request
    @trn_request ||= TrnRequest.find_by(id: session[:trn_request_id])
  end

  def trn_request_params
    params.require(:trn_request).permit(:answers_checked)
  end
end
