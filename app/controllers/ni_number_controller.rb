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
      reset_and_attempt_to_find_a_trn
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
end
