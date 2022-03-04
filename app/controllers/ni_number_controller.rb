# frozen_string_literal: true
class NiNumberController < ApplicationController
  def new; end

  def create
    if trn_request.update(has_ni_number: trn_request_params[:has_ni_number])
      session[:trn_request_id] = trn_request.id
      redirect_to trn_request.has_ni_number? ? ni_number_url : itt_provider_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if ni_number.update(ni_number_params)
      redirect_to ni_number.email? ? check_answers_url : itt_provider_url
    else
      render :edit
    end
  end

  private

  def ni_number
    @ni_number ||= NiNumber.new(trn_request_id: session[:trn_request_id])
  end
  helper_method :ni_number

  def ni_number_params
    params.require(:ni_number).permit(:ni_number)
  end

  def trn_request
    @trn_request ||= TrnRequest.find_by(id: session[:trn_request_id]) || TrnRequest.new
  end
  helper_method :trn_request

  def trn_request_params
    params.require(:trn_request).permit(:has_ni_number, :ni_number)
  end
end
