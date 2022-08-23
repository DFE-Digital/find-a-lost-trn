# frozen_string_literal: true
class UnlockTeacherAccountJob < ApplicationJob
  def perform(uid:)
    DqtApi.unlock_teacher!(uid:)
  end
end
