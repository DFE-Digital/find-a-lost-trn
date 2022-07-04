# frozen_string_literal: true
class NiNumberController < ApplicationController
  include EnforceQuestionOrder

  def edit
    @ni_number = NiNumberForm.new(trn_request:)
  end

  def update
    @ni_number = NiNumberForm.new(trn_request:)
    if ni_number_not_known?
      redirect_to(
        (session[:form_complete] ? check_answers_path : itt_provider_path)
      )
    elsif @ni_number.update(ni_number_params)
      begin
        find_trn_using_api unless @trn_request.trn

        redirect_to @ni_number.email? ? check_answers_url : email_url
      rescue DqtApi::ApiError,
             Faraday::ConnectionFailed,
             Faraday::TimeoutError,
             DqtApi::TooManyResults,
             DqtApi::NoResults
        redirect_to @ni_number.email? ? check_answers_url : awarded_qts_url
      end
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
      has_active_sanctions: response["hasActiveSanctions"]
    )
  end
end
