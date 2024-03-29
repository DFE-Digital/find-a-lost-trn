# frozen_string_literal: true
class EmailController < ApplicationController
  include EnforceQuestionOrder

  before_action :redirect_requests_from_identity

  layout "two_thirds"

  def edit
    @email_form = EmailForm.new(trn_request:)
  end

  def update
    @email_form = EmailForm.new(email: email_params[:email], trn_request:)
    if @email_form.save
      reset_and_attempt_to_find_a_trn
      next_question
    else
      render :edit
    end
  end

  private

  def email_params
    params.require(:email_form).permit(:email)
  end
end
