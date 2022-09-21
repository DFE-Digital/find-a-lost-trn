# frozen_string_literal: true
class CheckTrnController < ApplicationController
  layout "two_thirds"

  def new
    @check_trn_form = CheckTrnForm.new
  end

  def create
    @check_trn_form = CheckTrnForm.new(check_trn_params)
    if @check_trn_form.valid?
      redirect_to(
        (@check_trn_form.trn? ? ask_questions_path : you_dont_have_a_trn_path),
      )
    else
      render :new
    end
  end

  private

  def check_trn_params
    params.require(:check_trn_form).permit(:has_trn)
  end
end
