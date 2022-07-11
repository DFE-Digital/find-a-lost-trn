# frozen_string_literal: true

class PerformanceController < ApplicationController
  LAUNCH_DATE = Date.new(2022, 5, 4).beginning_of_day

  def index
    stats = PerformanceStats.new(1.week.ago.beginning_of_day..Time.zone.now)

    @total_requests_by_day, @request_counts_by_day = stats.request_counts_by_day
    @duration_averages, @duration_usage = stats.duration_usage
  end
end
