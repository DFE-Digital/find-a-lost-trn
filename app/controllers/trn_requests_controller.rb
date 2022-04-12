# frozen_string_literal: true
class TrnRequestsController < ApplicationController
  include EnforceQuestionOrder

  def show
    redirect_to root_url unless trn_request
    session[:form_complete] = true
  end

  def update # rubocop:disable Metrics/AbcSize
    redirect_to root_url unless trn_request
    session[:form_complete] = false

    update_trn_request
    unless FeatureFlag.active?(:use_dqt_api)
      ZendeskService.create_ticket!(trn_request)
      TeacherMailer.information_received(trn_request).deliver_now
      redirect_to helpdesk_request_submitted_url
      return
    end

    begin
      response = DqtApi.find_trn!(trn_request)
      trn_request.update(trn: response['trn'])
      TeacherMailer.found_trn(trn_request).deliver_now
      redirect_to trn_found_path
    rescue DqtApi::ApiError, Faraday::ConnectionFailed, Faraday::TimeoutError, DqtApi::TooManyResults
      ZendeskService.create_ticket!(trn_request)
      TeacherMailer.information_received(trn_request).deliver_now
      redirect_to helpdesk_request_submitted_url
    end
  end

  private

  def trn_request_params
    params.require(:trn_request).permit(:answers_checked)
  end

  def update_trn_request
    trn_request.update(trn_request_params)
  end
end
