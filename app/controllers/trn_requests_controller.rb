# frozen_string_literal: true
class TrnRequestsController < ApplicationController
  class TrnHasAlert < StandardError
  end

  include EnforceQuestionOrder

  def show
    redirect_to root_url unless trn_request
    session[:form_complete] = true
  end

  def update
    redirect_to root_url unless trn_request
    session[:form_complete] = false

    update_trn_request

    begin
      find_trn_using_api unless trn_request.trn
      raise TrnHasAlert if trn_request.has_active_sanctions

      TeacherMailer.found_trn(trn_request).deliver_now

      redirect_to trn_found_path
    rescue DqtApi::NoResults
      redirect_to no_match_path
    rescue DqtApi::ApiError,
           Faraday::ConnectionFailed,
           Faraday::TimeoutError,
           DqtApi::TooManyResults,
           TrnHasAlert
      create_zendesk_ticket

      redirect_to helpdesk_request_submitted_path
    end
  end

  private

  def trn_request_params
    params.require(:trn_request).permit(:answers_checked)
  end

  def update_trn_request
    trn_request.update(trn_request_params)
  end

  def find_trn_using_api
    response = DqtApi.find_trn!(trn_request)
    trn_request.update!(
      trn: response["trn"],
      has_active_sanctions: response["hasActiveSanctions"]
    )
  end

  def create_zendesk_ticket
    ZendeskService.create_ticket!(trn_request)
    TeacherMailer.information_received(trn_request).deliver_now
    CheckZendeskTicketForTrnJob.set(wait: 2.days).perform_later(trn_request.id)
  end
end
