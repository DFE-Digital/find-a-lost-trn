# frozen_string_literal: true
class PerformanceAlertJob < ApplicationJob
  include ActionView::Helpers::TextHelper

  def perform
    count = TrnRequest.where(created_at: 1.week.ago.beginning_of_day..Time.zone.now).count
    message =
      "There have been #{pluralize(count, 'TRN request')} started in the last 7 days on https://find-a-lost-trn.education.gov.uk/performance"
    SlackClient.create_message(message)
  end
end
