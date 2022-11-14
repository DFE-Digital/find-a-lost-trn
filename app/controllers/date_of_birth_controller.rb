# frozen_string_literal: true
class DateOfBirthController < ApplicationController
  include EnforceQuestionOrder

  layout "two_thirds"

  def edit
  end

  def update
    if date_of_birth_form.update(date_of_birth_params)
      reset_and_attempt_to_find_a_trn
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
end
