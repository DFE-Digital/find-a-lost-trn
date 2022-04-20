# frozen_string_literal: true

class PagesController < ApplicationController
  def helpdesk_request_submitted
    @trn_request = TrnRequest.find_by(id: session[:trn_request_id])
    redirect_to root_url unless @trn_request
    reset_session
  end

  def trn_found
    @trn_request = TrnRequest.find_by(id: session[:trn_request_id])
    redirect_to root_url unless @trn_request
    reset_session
  end

  def start
    session[:form_complete] = false
  end

  def performance # rubocop:disable Metrics/AbcSize
    trn_requests = TrnRequest.order(created_at: :desc).where(created_at: 1.week.ago.beginning_of_day..Time.zone.now)

    trn_requests_from_days_ago = (0..6).map { |n| trn_requests.where(created_at: n.days.ago.all_day) }

    @requests_over_last_7_days = trn_requests.count

    @live_service_data = [%w[Date Requests]]
    @live_service_data +=
      trn_requests_from_days_ago.map.with_index { |reqs, i| [i.days.ago.strftime('%d %B'), reqs.count] }

    @trns_found = trn_requests.where.not(trn: nil).count

    @submission_data = [['Date', 'TRNs found', 'Zendesk tickets opened']]
    @submission_data +=
      trn_requests_from_days_ago.map.with_index do |reqs, i|
        [i.days.ago.strftime('%d %B'), reqs.where.not(trn: nil).count, reqs.where.not(zendesk_ticket_id: nil).count]
      end
  end
end
