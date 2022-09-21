# frozen_string_literal: true
class DateOfBirthController < ApplicationController
  include EnforceQuestionOrder

  layout "two_thirds"

  def edit
  end

  def update
    if date_of_birth_form.update(date_of_birth_params)
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

  def date_of_birth_form
    @date_of_birth_form ||= DateOfBirthForm.new(trn_request:)
  end
  helper_method :date_of_birth_form

  def date_of_birth_params
    params.require(:date_of_birth_form).permit(
      "date_of_birth(3i)",
      "date_of_birth(2i)",
      "date_of_birth(1i)",
    )
  end

  def find_trn_using_api
    response = DqtApi.find_trn!(@trn_request)
    @trn_request.update!(
      trn: response["trn"],
      has_active_sanctions: response["hasActiveSanctions"],
    )
  end
end
