# frozen_string_literal: true
class TrnRequest < ApplicationRecord
  def answers_checked=(value)
    return unless value

    self.checked_at = Time.current
  end
end
