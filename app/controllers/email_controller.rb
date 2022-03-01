# frozen_string_literal: true
class EmailController < ApplicationController
  def edit
    @trn_request = TrnRequest.find_by(id: session[:trn_request_id]) || TrnRequest.new
  end

  def update
    @trn_request = TrnRequest.find_by(id: session[:trn_request_id]) || TrnRequest.new
    if @trn_request.update(email: email_params[:email])
      redirect_to check_answers_url
    else
      render :edit
    end
  end

  private

  def email_params
    params.require(:trn_request).permit(:email)
  end
end
