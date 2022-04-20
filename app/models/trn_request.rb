# frozen_string_literal: true
class TrnRequest < ApplicationRecord
  def answers_checked=(value)
    return unless value

    self.checked_at = Time.current
  end

  def itt_provider_answered?
    !itt_provider_enrolled.nil? && !itt_provider_enrolled_was.nil?
  end

  def previous_name?
    previous_first_name.present? || previous_last_name.present?
  end

  def previous_name
    [previous_first_name.presence || first_name, previous_last_name.presence || last_name].join(' ')
  end

  def name
    [first_name, last_name].compact.join(' ')
  end

  def ni_number_answered?
    return ni_number.present? if has_ni_number

    !has_ni_number.nil? && !has_ni_number_was.nil?
  end

  def status # rubocop:disable Metrics
    return :answers if email.present?
    return :email if (!awarded_qts.nil? && !awarded_qts && itt_provider_enrolled.nil?) || !itt_provider_enrolled.nil?
    return :itt_provider if awarded_qts
    return :awarded_qts if (!has_ni_number.nil? && ni_number.present?) || (!has_ni_number.nil? && !has_ni_number)
    return :ni_number if has_ni_number
    return :has_ni_number if date_of_birth.present?
    return :date_of_birth if first_name.present?

    :name
  end
end
