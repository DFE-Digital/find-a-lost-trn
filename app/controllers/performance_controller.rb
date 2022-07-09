# frozen_string_literal: true

class PerformanceController < ApplicationController
  def index
    time_period = 1.week.ago.beginning_of_day..Time.zone.now
    @since_text = "over the last 7 days"
    @short_since_text = "last 7 days"

    if params.key? :since_launch
      launch_date = Date.new(2022, 5, 4).beginning_of_day
      time_period = launch_date..Time.zone.now
      @since_text = "since launch"
      @short_since_text = "since launch"
    end

    stats = PerformanceStats.new(time_period)

    @total_requests_by_day, @request_counts_by_day = stats.request_counts_by_day
    @duration_averages, @duration_usage = stats.duration_usage
  end
end
