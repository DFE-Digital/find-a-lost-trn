# frozen_string_literal: true

class PagesController < ApplicationController
  def helpdesk_request_delayed
    @trn_request = TrnRequest.find_by(id: session[:trn_request_id])
    redirect_to root_url unless @trn_request
    reset_session
  end

  def helpdesk_request_submitted
    @trn_request = TrnRequest.find_by(id: session[:trn_request_id])
    redirect_to root_url unless @trn_request
    reset_session
  end

  def trn_found
    @trn_request = TrnRequest.find_by(id: session[:trn_request_id])
    redirect_to root_url unless @trn_request
    reset_session
  end

  def start
    session[:form_complete] = false

    if session[:identity_client_url]
      redirect_to session[:identity_client_url], allow_other_host: true
      reset_session
    end
  end
end
