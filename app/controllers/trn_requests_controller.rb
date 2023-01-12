# frozen_string_literal: true
class TrnRequestsController < ApplicationController
  class TrnHasAlert < StandardError
  end

  include EnforceQuestionOrder

  layout "two_thirds"

  def show
    redirect_to root_url unless trn_request
    session[:form_complete] = true
  end

  def update
    redirect_to root_url unless trn_request
    session[:form_complete] = false

    update_answers_checked_on_trn_request

    begin
      find_trn_using_api unless trn_request.trn
      if trn_request.has_active_sanctions && !trn_request.from_get_an_identity?
        raise TrnHasAlert
      end

      if trn_request.from_get_an_identity?
        # Send a request to Get An Identity API with the TRN for the journey
        IdentityApi.submit_trn!(trn_request, session[:identity_journey_id])
        session[:identity_trn_request_sent] = true

        # Send the user back to Get an Identity
        redirect_to session[:identity_redirect_url], allow_other_host: true
        session[:identity_client_title] = nil
      else
        TeacherMailer.found_trn(trn_request).deliver_later
        redirect_to trn_found_path
      end
    rescue DqtApi::NoResults
      redirect_to no_match_path
    rescue DqtApi::ApiError,
           Faraday::ConnectionFailed,
           Faraday::TimeoutError,
           DqtApi::TooManyResults,
           TrnHasAlert
      begin
        create_zendesk_ticket
        redirect_to helpdesk_request_submitted_path
      rescue ZendeskService::ConnectionError => e
        Sentry.capture_exception(e)
        CreateZendeskTicketJob.set(wait: 5.minutes).perform_later(
          trn_request.id,
        )
        TeacherMailer.delayed_information_received(trn_request).deliver_later
        redirect_to helpdesk_request_delayed_path
      end
    end
  end

  private

  def answers_checked_params
    params.require(:trn_request).permit(:answers_checked)
  end

  def update_answers_checked_on_trn_request
    trn_request.update(answers_checked_params)
  end

  def create_zendesk_ticket
    ZendeskService.create_ticket!(trn_request)
    TeacherMailer.information_received(trn_request).deliver_later
    CheckZendeskTicketForTrnJob.set(wait: 2.days).perform_later(trn_request.id)
  end
end
