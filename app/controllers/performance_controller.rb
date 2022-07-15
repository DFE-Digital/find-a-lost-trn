# frozen_string_literal: true

class PerformanceController < ApplicationController
  def index
    stats = PerformanceStats.new

    @total_requests_by_day, @request_counts_by_day = stats.request_counts_by_day
    @total_requests_by_month, @request_counts_by_month =
      stats.request_counts_by_month
    @duration_averages, @duration_usage = stats.duration_usage
    @journeys = stats.journeys
  end
end
