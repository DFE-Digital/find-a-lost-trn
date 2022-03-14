# frozen_string_literal: true
class EmailController < ApplicationController
  def edit
    trn_request = TrnRequest.find_by(id: session[:trn_request_id])
    @email_form = EmailForm.new(trn_request: trn_request)
  end

  def update
    trn_request = TrnRequest.find_by(id: session[:trn_request_id])
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
