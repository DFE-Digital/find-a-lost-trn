# frozen_string_literal: true
class TrnRequestsController < ApplicationController
  def create
    @trn_request =
      TrnRequest.create(
        date_of_birth: '1955-11-12',
        email: 'email@example.com',
        name: 'Jane Doe',
        ni_number: 'QQ123456C',
      )
    session[:trn_request_id] = @trn_request.id
    redirect_to check_answers_url
  end

  def show
    redirect_to root_url unless trn_request
  end

  def update
    redirect_to root_url unless trn_request

    trn_request.update(trn_request_params)
    redirect_to helpdesk_request_submitted_url
  end

  private

  def trn_request
    @trn_request ||= TrnRequest.find_by(id: session[:trn_request_id])
  end

  def trn_request_params
    params.require(:trn_request).permit(:answers_checked)
  end
end
