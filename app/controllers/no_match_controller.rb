# frozen_string_literal: true
class NoMatchController < ApplicationController
  include EnforceQuestionOrder

  layout "two_thirds"

  def new
    @no_match_form = NoMatchForm.new
  end

  def create
    @no_match_form = NoMatchForm.new(no_match_params)
    if @no_match_form.valid? && @no_match_form.try_again?
      redirect_to check_answers_path
    elsif @no_match_form.valid?
      return redirect_to_completed_submission unless claim_submission!

      if trn_request.from_get_an_identity?
        # Send a request to Get An Identity API with no TRN found
        IdentityApi.submit_trn!(trn_request, session[:identity_journey_id])
        session[:identity_trn_request_sent] = true

        # Send the user to the redirect url specified by the client app
        redirect_to session[:identity_redirect_url], allow_other_host: true
        session[:identity_client_title] = nil
      else
        begin
          create_zendesk_ticket
        rescue ZendeskService::ConnectionError
          # The connection error is raised before the ticket is created, so the
          # side effect has not committed: release the claim to keep the
          # submission retryable, then re-raise so the failure still surfaces.
          # Deliberately narrow — releasing after a committed side effect (a sent
          # Identity submission, or a created ticket) would let a replay repeat it.
          release_submission!
          raise
        end

        redirect_to helpdesk_request_submitted_path
      end
    else
      render :new
    end
  end

  private

  def no_match_params
    params.require(:no_match_form).permit(:try_again)
  end

  def create_zendesk_ticket
    ZendeskService.create_ticket!(trn_request)
    TeacherMailer.information_received(trn_request).deliver_later
    CheckZendeskTicketForTrnJob.set(wait: 2.days).perform_later(trn_request.id)
  end
end
