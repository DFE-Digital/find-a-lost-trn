# frozen_string_literal: true
class IttProvidersController < ApplicationController
  def edit
    trn_request
  end

  def update
    if trn_request.update!(itt_provider_params)
      session[:trn_request_id] = trn_request.id
      redirect_to trn_request.email.blank? ? email_url : check_answers_url
    else
      render :edit
    end
  end

  private

  def itt_provider_params
    params.require(:trn_request).permit(:itt_provider_enrolled, :itt_provider_name)
  end

  def trn_request
    @trn_request ||= TrnRequest.find_by(id: session[:trn_request_id]) || TrnRequest.new
  end
end
