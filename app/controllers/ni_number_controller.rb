# frozen_string_literal: true
class NiNumberController < ApplicationController
  include EnforceQuestionOrder

  layout "two_thirds"

  def edit
    @ni_number = NiNumberForm.new(trn_request:)
  end

  def update
    @ni_number = NiNumberForm.new(trn_request:)
    if ni_number_not_known?
      session[:ni_number_not_known] = true
      next_question
    elsif @ni_number.update(ni_number_params)
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
      render :edit
    end
  end

  private

  def ni_number_params
    params.require(:ni_number_form).permit(:ni_number)
  end

  def ni_number_not_known?
    params.require(:submit) == "ni_number_not_known"
  end

  def find_trn_using_api
    response = DqtApi.find_trn!(@trn_request)
    @trn_request.update!(
      trn: response["trn"],
      has_active_sanctions: response["hasActiveSanctions"],
    )
  end
end
