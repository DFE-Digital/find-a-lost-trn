module SupportInterface
  class ZendeskPerformanceController < SupportInterfaceController
    def index
      @total =
        ZendeskDeleteRequest
          .no_duplicates
          .where(closed_at: PerformanceStats::LAUNCH_DATE..)
          .count
      @last_7_days =
        ZendeskDeleteRequest.no_duplicates.where(closed_at: 7.days.ago..).count

      requests_by_month =
        ZendeskDeleteRequest
          .no_duplicates
          .select(
            Arel.sql("date_trunc('month', closed_at) AS month"),
            Arel.sql("count(*) AS total"),
          )
          .group("date_trunc('month', closed_at)")
          .order(Arel.sql("date_trunc('month', closed_at) desc"))
          .each_with_object({}) do |row, hash|
            hash[row["month"]] = row
              .attributes
              .except("id", "month")
              .symbolize_keys
          end

      @request_counts_by_month =
        requests_by_month.map do |month, requests|
          [month.to_fs(:month_and_year), requests]
        end

      @total_requests_by_month =
        %i[total].index_with do |key|
          requests_by_month.map(&:last).collect { |attr| attr[key] }.reduce(&:+)
        end

      requests_by_week =
        ZendeskDeleteRequest
          .no_duplicates
          .where(closed_at: 12.weeks.ago.beginning_of_week.beginning_of_day..)
          .select(
            Arel.sql("date_trunc('week', closed_at) AS week"),
            Arel.sql("count(*) AS total"),
          )
          .group("date_trunc('week', closed_at)")
          .order(Arel.sql("date_trunc('week', closed_at) desc"))
          .each_with_object({}) do |row, hash|
            hash[row["week"]] = row
              .attributes
              .except("id", "week")
              .symbolize_keys
          end

      @request_counts_by_week =
        requests_by_week.map do |week, requests|
          [week.to_fs(:week_and_year), requests]
        end

      @total_requests_by_week =
        %i[total].index_with do |key|
          requests_by_week.map(&:last).collect { |attr| attr[key] }.reduce(&:+)
        end
    end
  end
end
