# frozen_string_literal: true
class DateOfBirthForm
  include ActiveModel::Model

  attr_accessor :trn_request
  attr_writer :date_of_birth

  validates :date_of_birth,
            presence: true,
            inclusion: {
              in: Date.new(1900, 1, 1)..16.years.ago.to_date,
              if: :date_of_birth,
            }

  delegate :email?, to: :trn_request, allow_nil: true

  def date_of_birth
    @date_of_birth ||= trn_request&.date_of_birth
  end

  def update(params = {})
    date_fields = [params['date_of_birth(1i)'], params['date_of_birth(2i)'], params['date_of_birth(3i)']]
    begin
      self.date_of_birth = Date.new(*date_fields.map(&:to_i)) unless date_fields.any?(&:blank?)
    rescue Date::Error
      errors.add(:date_of_birth, I18n.t('activemodel.errors.models.date_of_birth_form.attributes.date_of_birth.blank'))
      return false
    end

    return false if invalid?

    trn_request.update!(date_of_birth: date_of_birth)
  end
end
