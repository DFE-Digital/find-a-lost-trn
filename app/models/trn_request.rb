# frozen_string_literal: true

# == Schema Information
#
# Table name: trn_requests
#
#  id                      :bigint           not null, primary key
#  awarded_qts             :boolean
#  checked_at              :datetime
#  date_of_birth           :date
#  email                   :string(510)
#  first_name              :string(510)
#  from_get_an_identity    :boolean          default(FALSE)
#  has_active_sanctions    :boolean
#  has_ni_number           :boolean
#  itt_provider_enrolled   :boolean
#  itt_provider_name       :string
#  itt_provider_ukprn      :string
#  last_name               :string(510)
#  name_changed            :boolean
#  ni_number               :string(510)
#  official_name_preferred :boolean
#  preferred_first_name    :string
#  preferred_last_name     :string
#  previous_first_name     :string(510)
#  previous_last_name      :string(510)
#  trn                     :string
#  trn_from_user           :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  zendesk_ticket_id       :integer
#
class TrnRequest < ApplicationRecord
  encrypts :email, deterministic: true
  encrypts :first_name,
           :last_name,
           :ni_number,
           :previous_first_name,
           :previous_last_name

  has_many :trn_responses, dependent: :destroy
  has_many :account_unlock_events

  scope :with_zendesk_ticket, -> { where.not(zendesk_ticket_id: nil) }
  scope :since_launch, -> { where(created_at: PerformanceStats::LAUNCH_DATE..) }

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
    [
      previous_first_name.presence || first_name,
      previous_last_name.presence || last_name,
    ].join(" ")
  end

  def name
    return preferred_name if preferred_name?

    official_name
  end

  def official_name
    [first_name, last_name].compact.join(" ")
  end

  def preferred_name
    [preferred_first_name, preferred_last_name].compact.join(" ")
  end

  def preferred_name?
    preferred_name.present?
  end

  def ni_number_answered?
    return ni_number.present? if has_ni_number

    !has_ni_number.nil? && !has_ni_number_was.nil?
  end

  # Detect if the same email has successfully requested a different TRN
  def previous_trn_success_for_email?
    return false if trn.blank?
    TrnRequest.where(email:).where.not(trn:).exists?
  end

  def itt_provider_name_for_dqt
    itt_provider_ukprn.present? ? nil : itt_provider_name
  end

  def first_unlocked_at
    account_unlock_events.order(created_at: :asc).first&.created_at
  end

  def self.to_csv(scope = since_launch)
    attributes = %w[id trn email first_unlocked_at created_at updated_at]

    CSV.generate(headers: true) do |csv|
      csv << attributes.map(&:titleize)

      scope.find_each do |trn_request|
        csv << attributes.map { |attr| trn_request.send(attr) }
      end
    end
  end
end
