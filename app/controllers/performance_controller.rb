# frozen_string_literal: true

class PerformanceController < ApplicationController
  def index
    stats = PerformanceStats.new

    @total_requests_by_day, @request_counts_by_day = stats.request_counts_by_day
    @duration_averages, @duration_usage = stats.duration_usage
  end
end
