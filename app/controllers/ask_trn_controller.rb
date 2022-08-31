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
      next_question
    else
      render :new
    end
  end

  private

  def trn_params
    params.require(:ask_trn_form).permit(:do_you_know_your_trn, :trn_from_user)
  end
end