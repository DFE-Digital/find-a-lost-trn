# frozen_string_literal: true
# rubocop:disable Metrics/AbcSize
class PerformanceStats
  def initialize(time_period)
    raise ArgumentError, 'time_period is not a Range' unless time_period.is_a? Range

    number_of_days_in_period = ((Time.zone.now.beginning_of_day - time_period.first) / 1.day).to_i

    @trn_requests = TrnRequest.where(created_at: time_period).group("date_trunc('day', created_at)")

    @last_n_days = (0..number_of_days_in_period).map { |n| n.days.ago.beginning_of_day.utc }

    calculate_live_service_usage
    calculate_submission_results
    calculate_duration_usage
  end

  def live_service_usage
    [@requests_over_last_n_days, @live_service_data]
  end

  def submission_results
    [@trns_found, @submission_data]
  end

  def duration_usage
    @duration_data
  end

  private

  def calculate_live_service_usage
    trn_requests_total = @trn_requests.count

    @requests_over_last_n_days = trn_requests_total.values.reduce(&:+)

    @live_service_data = [%w[Date Requests]]
    @live_service_data += @last_n_days.map { |day| [day.strftime('%d %B'), trn_requests_total[day] || 0] }
  end

  def calculate_submission_results
    trn_requests_with_trn = @trn_requests.where.not(trn: nil).count
    trn_requests_with_zendesk_ticket = @trn_requests.where.not(zendesk_ticket_id: nil).count

    @trns_found = trn_requests_with_trn.values.reduce(&:+)

    @submission_data = [['Date', 'TRNs found', 'Zendesk tickets opened']]
    @submission_data +=
      @last_n_days.map do |day|
        [day.strftime('%d %B'), trn_requests_with_trn[day] || 0, trn_requests_with_zendesk_ticket[day] || 0]
      end
  end

  def calculate_duration_usage
    percentiles_by_day =
      @trn_requests
        .where.not(checked_at: nil)
        .group('1')
        .pluck(
          Arel.sql("date_trunc('day', created_at) AS day"),
          Arel.sql('percentile_cont(0.90) within group (order by (checked_at - created_at) asc) as percentile_90'),
          Arel.sql('percentile_cont(0.75) within group (order by (checked_at - created_at) asc) as percentile_75'),
          Arel.sql('percentile_cont(0.50) within group (order by (checked_at - created_at) asc) as percentile_50'),
        )
        .each_with_object({}) { |row, hash| hash[row[0]] = row.slice(1, 3) }

    @duration_data = [['Date', '90% of users within', '75% of users within', '50% of users within']]
    @duration_data +=
      @last_n_days.map do |day|
        percentiles = percentiles_by_day[day] || [0, 0, 0]
        [day.strftime('%d %B')] + percentiles.map { |value| ActiveSupport::Duration.build(value.to_i).inspect }
      end
  end
end
# rubocop:enable Metrics/AbcSize
