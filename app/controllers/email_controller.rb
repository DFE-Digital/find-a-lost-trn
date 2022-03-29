# frozen_string_literal: true
class EmailController < ApplicationController
  include EnforceQuestionOrder

  def edit
    @email_form = EmailForm.new(trn_request: trn_request)
  end

  def update
    @email_form = EmailForm.new(email: email_params[:email], trn_request: trn_request)
    if @email_form.save
      redirect_to check_answers_url
    else
      render :edit
    end
  end

  private

  def email_params
    params.require(:email_form).permit(:email)
  end
end
