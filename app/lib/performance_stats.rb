# frozen_string_literal: true
class PerformanceStats
  include ActionView::Helpers::NumberHelper

  def initialize(time_period)
    unless time_period.is_a? Range
      raise ArgumentError, "time_period is not a Range"
    end

    number_of_days_in_period =
      ((Time.zone.now.beginning_of_day - time_period.first) / 1.day).to_i

    @trn_requests =
      TrnRequest.where(created_at: time_period).group(
        "date_trunc('day', created_at)"
      )

    @last_n_days =
      (0..number_of_days_in_period).map { |n| n.days.ago.beginning_of_day.utc }

    calculate_request_counts_by_day
    calculate_duration_usage
  end

  def live_service_usage
    @requests_over_last_n_days
  end

  def duration_usage
    [@duration_averages, @duration_data]
  end

  def request_counts_by_day
    [@total_requests_by_day, @request_counts_by_day]
  end

  private

  def calculate_request_counts_by_day
    sparse_request_counts_by_day =
      @trn_requests
        .select(
          Arel.sql("date_trunc('day', created_at) AS day"),
          Arel.sql(
            "sum(case when trn is not null then 1 else 0 end) as cnt_trn_found"
          ),
          Arel.sql(
            "sum(case when zendesk_ticket_id is not null then 1 else 0 end) as cnt_no_match"
          ),
          Arel.sql(
            "sum(case when trn is null and zendesk_ticket_id is null then 1 else 0 end) as cnt_did_not_finish"
          ),
          Arel.sql("count(*) as total")
        )
        .each_with_object({}) do |row, hash|
          hash[row["day"]] = row.attributes.except("id", "day").symbolize_keys
        end

    @request_counts_by_day =
      @last_n_days.map do |day|
        requests =
          sparse_request_counts_by_day[day] ||
            {
              total: 0,
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 0
            }
        [day.to_fs(:day_and_month), requests]
      end

    @total_requests_by_day =
      %i[
        total
        cnt_trn_found
        cnt_no_match
        cnt_did_not_finish
      ].index_with do |key|
        sparse_request_counts_by_day
          .map(&:last)
          .collect { |attr| attr[key] }
          .reduce(&:+)
      end
  end

  def calculate_duration_usage
    percentiles_by_day =
      @trn_requests
        .where.not(checked_at: nil)
        .where.not(trn: nil)
        .group("1")
        .pluck(
          Arel.sql("date_trunc('day', created_at) AS day"),
          Arel.sql(
            "percentile_disc(0.90) within group (order by (checked_at - created_at) asc) as percentile_90"
          ),
          Arel.sql(
            "percentile_disc(0.75) within group (order by (checked_at - created_at) asc) as percentile_75"
          ),
          Arel.sql(
            "percentile_disc(0.50) within group (order by (checked_at - created_at) asc) as percentile_50"
          )
        )
        .each_with_object({}) { |row, hash| hash[row[0]] = row.slice(1, 3) }

    average_percentiles =
      @trn_requests
        .unscope(:group)
        .where.not(checked_at: nil)
        .where.not(trn: nil)
        .pick(
          Arel.sql(
            "percentile_disc(0.90) within group (order by (checked_at - created_at) asc) as percentile_90"
          ),
          Arel.sql(
            "percentile_disc(0.75) within group (order by (checked_at - created_at) asc) as percentile_75"
          ),
          Arel.sql(
            "percentile_disc(0.50) within group (order by (checked_at - created_at) asc) as percentile_50"
          )
        )

    @duration_data =
      @last_n_days.map do |day|
        percentiles = percentiles_by_day[day] || [0, 0, 0]
        [day.to_fs(:day_and_month)] +
          percentiles.map do |value|
            ActiveSupport::Duration.build(value.to_i).inspect
          end
      end

    @duration_averages =
      (average_percentiles || [0, 0, 0]).map do |value|
        ActiveSupport::Duration.build(value.to_i).inspect
      end
  end
end
