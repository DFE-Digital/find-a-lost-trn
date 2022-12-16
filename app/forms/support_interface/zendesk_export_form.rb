module SupportInterface
  class ZendeskExportForm
    include ActiveModel::Model

    attr_accessor :time_period

    def filename
      time_period_string = time_period.to_time&.strftime("%Y_%m_%d") || "all"

      "#{time_period_string}_deleted_zendesk_tickets.csv"
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
          scope = ZendeskDeleteRequest.since_launch.no_duplicates
          if time_period.present?
            case time_period
            when "all"
              scope
            else
              start = time_period.to_time.beginning_of_month
              closed_at = [start..start.end_of_month]
              scope = scope.where(closed_at:)
            end
          end
          scope
        end
    end
  end
end
