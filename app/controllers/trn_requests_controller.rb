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

    update_trn_request

    begin
      find_trn_using_api unless trn_request.trn
      raise TrnHasAlert if trn_request.has_active_sanctions

      if trn_request.from_get_an_identity?
        begin
          # Send a request to Get An Identity API with the TRN for the journey
          IdentityApi.submit_trn!(trn_request, session[:identity_journey_id])

          # Send the user back to Get an Identity
          redirect_to session[:identity_redirect_uri], allow_other_host: true
          reset_session
        rescue IdentityApi::ApiError,
               Faraday::ConnectionFailed,
               Faraday::TimeoutError,
               ActionController::ActionControllerError => e
          Sentry.capture_exception(e)
          # Do not redirect back to Get An Identity
          render "errors/internal_server_error", status: :internal_server_error
        end
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
      rescue ZendeskService::ConnectionError => exception
        Sentry.capture_exception(exception)
        CreateZendeskTicketJob.set(wait: 5.minutes).perform_later(
          trn_request.id
        )
        TeacherMailer.delayed_information_received(trn_request).deliver_later
        redirect_to helpdesk_request_delayed_path
      end
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
    TeacherMailer.information_received(trn_request).deliver_later
    CheckZendeskTicketForTrnJob.set(wait: 2.days).perform_later(trn_request.id)
  end
end
