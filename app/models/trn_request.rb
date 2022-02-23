# frozen_string_literal: true
class TrnRequest < ApplicationRecord
  validates :email, valid_for_notify: true, if: %i[itt_provider_answered? ni_number_answered?]
  validates :itt_provider_enrolled, presence: true, inclusion: { in: [true, false] }, if: %i[ni_number_answered?]
  validates :itt_provider_name, allow_blank: true, length: { maximum: 255 }

  def answers_checked=(value)
    return unless value

    self.checked_at = Time.current
  end

  def itt_provider_answered?
    !itt_provider_enrolled.nil? && !itt_provider_enrolled_was.nil?
  end

  def ni_number_answered?
    return ni_number.present? if has_ni_number

    !has_ni_number.nil? && !has_ni_number_was.nil?
  end
end
