# frozen_string_literal: true
class PerformanceStats
  include ActionView::Helpers::NumberHelper

  LAUNCH_DATE = Date.new(2022, 5, 4).beginning_of_day.freeze

  def initialize
    time_period = (1.week.ago.beginning_of_day..Time.zone.now)

    @trn_requests =
      TrnRequest.where(created_at: time_period).group(
        "date_trunc('day', created_at)",
      )

    @last_n_days = (0..7).map { |n| n.days.ago.beginning_of_day.utc }

    calculate_request_counts_by_day
    calculate_request_counts_by_month
    calculate_duration_usage
    calculate_journeys
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

  def request_counts_by_month
    [@total_requests_by_month, @request_counts_by_month]
  end

  attr_reader :journeys

  private

  def arel_columns_for_request_counts
    [
      Arel.sql(
        "sum(case when trn is not null and zendesk_ticket_id is null then 1 else 0 end) as cnt_trn_found",
      ),
      Arel.sql(
        "sum(case when zendesk_ticket_id is not null then 1 else 0 end) as cnt_no_match",
      ),
      Arel.sql(
        "sum(case when trn is null and zendesk_ticket_id is null then 1 else 0 end) as cnt_did_not_finish",
      ),
      Arel.sql("count(*) as total"),
    ]
  end

  def calculate_request_counts_by_day
    sparse_request_counts_by_day =
      @trn_requests
        .select(
          Arel.sql("date_trunc('day', created_at) AS day"),
          *arel_columns_for_request_counts,
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
              cnt_did_not_finish: 0,
            }
        date_string =
          day == Time.zone.today ? "Today" : day.to_fs(:weekday_day_and_month)
        [date_string, requests]
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
          .reduce(&:+) || 0
      end
  end

  def calculate_request_counts_by_month
    start_date = [
      LAUNCH_DATE,
      12.months.ago.beginning_of_month.beginning_of_day,
    ].max
    sparse_request_counts_by_month =
      TrnRequest
        .where(created_at: (start_date..Time.zone.now))
        .group("date_trunc('month', created_at)")
        .select(
          Arel.sql("date_trunc('month', created_at) AS month"),
          *arel_columns_for_request_counts,
        )
        .order(Arel.sql("date_trunc('month', created_at) desc"))
        .each_with_object({}) do |row, hash|
          hash[row["month"]] = row
            .attributes
            .except("id", "month")
            .symbolize_keys
        end

    @request_counts_by_month =
      sparse_request_counts_by_month.map do |month, counts|
        [month.to_fs(:month_and_year), counts]
      end

    @total_requests_by_month =
      %i[
        total
        cnt_trn_found
        cnt_no_match
        cnt_did_not_finish
      ].index_with do |key|
        sparse_request_counts_by_month
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
            "percentile_disc(0.90) within group (order by (checked_at - created_at) asc) as percentile_90",
          ),
          Arel.sql(
            "percentile_disc(0.75) within group (order by (checked_at - created_at) asc) as percentile_75",
          ),
          Arel.sql(
            "percentile_disc(0.50) within group (order by (checked_at - created_at) asc) as percentile_50",
          ),
        )
        .each_with_object({}) { |row, hash| hash[row[0]] = row.slice(1, 3) }

    average_percentiles =
      @trn_requests
        .unscope(:group)
        .where.not(checked_at: nil)
        .where.not(trn: nil)
        .pick(
          Arel.sql(
            "percentile_disc(0.90) within group (order by (checked_at - created_at) asc) as percentile_90",
          ),
          Arel.sql(
            "percentile_disc(0.75) within group (order by (checked_at - created_at) asc) as percentile_75",
          ),
          Arel.sql(
            "percentile_disc(0.50) within group (order by (checked_at - created_at) asc) as percentile_50",
          ),
        )

    @duration_data =
      @last_n_days.map do |day|
        percentiles = percentiles_by_day[day] || [0, 0, 0]
        date_string =
          day == Time.zone.today ? "Today" : day.to_fs(:weekday_day_and_month)
        [date_string] +
          percentiles.map do |value|
            ActiveSupport::Duration.build(value.to_i).inspect
          end
      end

    @duration_averages =
      (average_percentiles || [0, 0, 0]).map do |value|
        ActiveSupport::Duration.build(value.to_i).inspect
      end
  end

  def calculate_journeys
    @journeys =
      @trn_requests
        .unscope(:group)
        .where(
          "trn is not null or zendesk_ticket_id is not null",
        ) # filter out all abandonments
        .select(
          Arel.sql(
            "sum(case when trn is not null and zendesk_ticket_id is null and has_ni_number is null then 1 else 0 end) as three_questions", # rubocop:disable Layout/LineLength
          ),
          Arel.sql(
            "sum(case when trn is not null and zendesk_ticket_id is null and has_ni_number is not null and awarded_qts is null then 1 else 0 end) as four_questions", # rubocop:disable Layout/LineLength
          ),
          Arel.sql(
            "sum(case when trn is not null and zendesk_ticket_id is null and awarded_qts is not null then 1 else 0 end) as five_questions_matched", # rubocop:disable Layout/LineLength
          ),
          Arel.sql(
            "sum(case when zendesk_ticket_id is not null and awarded_qts is not null then 1 else 0 end) as five_questions_nomatch", # rubocop:disable Layout/LineLength
          ),
          Arel.sql("count(*) as total"),
        )
        .map(&:attributes)
        .first
        .except("id")
        .symbolize_keys
  end
end
