# frozen_string_literal: true
class UnlockTeacherAccountJob < ApplicationJob
  def perform(teacher_account)
    DqtApi.unlock_teacher!(teacher_account)
  end
end
