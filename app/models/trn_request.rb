# frozen_string_literal: true
class TrnRequest < ApplicationRecord
  validates :email, valid_for_notify: true

  def answers_checked=(value)
    return unless value

    self.checked_at = Time.current
  end
end
