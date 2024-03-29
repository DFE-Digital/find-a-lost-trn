# frozen_string_literal: true
class UnlockTeacherAccountJob < ApplicationJob
  sidekiq_options queue: "critical"

  def perform(uid:, trn_request_id:)
    unlocked = DqtApi.unlock_teacher!(uid:)
    AccountUnlockEvent.create!(trn_request_id:) if unlocked
  end
end
