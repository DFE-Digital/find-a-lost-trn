# frozen_string_literal: true
class AskTrnController < ApplicationController
  include EnforceQuestionOrder

  layout "two_thirds"

  def new
    @ask_trn_form = AskTrnForm.new(trn_request:).assign_form_values
  end

  def create
    @ask_trn_form = AskTrnForm.new(trn_request:)
    if @ask_trn_form.update(trn_params)
      begin
        find_trn_using_api unless @trn_request.trn
      rescue DqtApi::ApiError,
             Faraday::ConnectionFailed,
             Faraday::TimeoutError => e
        Sentry.capture_exception(e)
      rescue DqtApi::TooManyResults, DqtApi::NoResults
        # Do nothing.
      end
      next_question
    else
      render :new
    end
  end

  private

  def trn_params
    params.require(:ask_trn_form).permit(:do_you_know_your_trn, :trn_from_user)
  end

  def find_trn_using_api
    response = DqtApi.find_trn!(@trn_request)
    @trn_request.update!(
      trn: response["trn"],
      has_active_sanctions: response["hasActiveSanctions"]
    )
  end
end
