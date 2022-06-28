# frozen_string_literal: true

class PerformanceController < ApplicationController
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def index
    since = 1.week.ago.beginning_of_day
    until_days = 6
    @since_text = 'over the last 7 days'

    if params.key? :since_launch
      launch_date = Date.new(2022, 5, 4).beginning_of_day
      since = launch_date
      until_days = ((Time.zone.now.beginning_of_day - since) / (3600 * 24)).to_i
      @since_text = 'since launch'
    end

    trn_requests = TrnRequest.where(created_at: since..Time.zone.now).group("date_trunc('day', created_at)")

    trn_requests_total = trn_requests.count

    trn_requests_with_trn = trn_requests.where.not(trn: nil).count

    trn_requests_with_zendesk_ticket = trn_requests.where.not(zendesk_ticket_id: nil).count

    last_n_days = (0..until_days).map { |n| n.days.ago.beginning_of_day.utc }

    @requests_over_last_n_days = trn_requests_total.values.reduce(&:+)

    @live_service_data = [%w[Date Requests]]
    @live_service_data += last_n_days.map { |day| [day.strftime('%d %B'), trn_requests_total[day] || 0] }

    @trns_found = trn_requests_with_trn.values.reduce(&:+)

    @submission_data = [['Date', 'TRNs found', 'Zendesk tickets opened']]
    @submission_data +=
      last_n_days.map do |day|
        [day.strftime('%d %B'), trn_requests_with_trn[day] || 0, trn_requests_with_zendesk_ticket[day] || 0]
      end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
