# frozen_string_literal: true

class PagesController < ApplicationController
  def helpdesk_request_submitted
    @trn_request = TrnRequest.find_by(id: session[:trn_request_id])
    redirect_to root_url unless @trn_request
  end

  def trn_found
    @trn_request = TrnRequest.find_by(id: session[:trn_request_id])
    redirect_to root_url unless @trn_request
  end

  def start
    session[:form_complete] = false
  end
end
