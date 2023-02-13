require "csv"

module SupportInterface
  class TrnRequestExportForm
    include ActiveModel::Model

    attr_accessor :time_period

    def filename
      time_period_string = time_period.to_time&.strftime("%Y_%m_%d") || "all"

      "#{time_period_string}_trn_requests.csv"
    end

    def months
      @months ||=
        begin
          date = PerformanceStats::LAUNCH_DATE
          months = []
          while date < Time.current
            months << [
              date.beginning_of_month.strftime("%B %Y"),
              date.beginning_of_month,
            ]
            date = date.advance(months: 1)
          end
          months << %w[All all]
          months.reverse
        end
    end

    def scope
      @scope ||=
        begin
          scope = TrnRequest.since_launch
          if time_period.present?
            case time_period
            when "all"
              scope
            else
              start = time_period.to_time.beginning_of_month
              created_at = [start..start.end_of_month]
              scope = scope.where(created_at:)
            end
          end
          scope
        end
    end
  end
end
