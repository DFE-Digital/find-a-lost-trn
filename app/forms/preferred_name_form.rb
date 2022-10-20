# frozen_string_literal: true
class PreferredNameForm
  include ActiveModel::Model
  include LogErrors

  attr_accessor(:trn_request)

  attr_writer(
    :official_name_preferred,
    :preferred_first_name,
    :preferred_last_name,
  )

  delegate(:official_name, to: :trn_request)

  validates :official_name_preferred, inclusion: [true, false]
  validates :preferred_first_name,
            presence: {
              unless: :official_name_preferred,
            }
  validates :preferred_last_name, presence: { unless: :official_name_preferred }

  def save!
    unless valid?
      log_errors
      return
    end

    trn_request.official_name_preferred = official_name_preferred
    if official_name_preferred
      trn_request.preferred_first_name = nil
      trn_request.preferred_last_name = nil
    else
      trn_request.preferred_first_name = @preferred_first_name
      trn_request.preferred_last_name = @preferred_last_name
    end

    trn_request.save!
  end

  def official_name_preferred
    if @official_name_preferred.nil?
      trn_request.official_name_preferred
    else
      ActiveModel::Type::Boolean.new.cast(@official_name_preferred)
    end
  end

  def preferred_first_name
    @preferred_first_name || trn_request.preferred_first_name
  end

  def preferred_last_name
    @preferred_last_name || trn_request.preferred_last_name
  end
end
