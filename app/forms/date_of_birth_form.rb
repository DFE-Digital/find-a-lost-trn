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

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def update(params = {})
    date_fields = [params['date_of_birth(1i)'], params['date_of_birth(2i)'], params['date_of_birth(3i)']]

    # Use a struct instead of a date object to maintain what the user typed in,
    # and not transform the fields into other data types like integers that
    # Date.new is capable of accepting.
    self.date_of_birth = Struct.new(:year, :month, :day).new(*date_fields)

    year, month, day = date_fields.map(&:to_i)

    if day.zero? && month.zero? && year.zero?
      errors.add(:date_of_birth, t('blank'))
      return false
    end

    if day.zero?
      errors.add(:date_of_birth, t('missing_day'))
      return false
    end

    if month.zero?
      errors.add(:date_of_birth, t('missing_month'))
      return false
    end

    if year.zero?
      errors.add(:date_of_birth, t('missing_year'))
      return false
    end

    if year > Time.zone.today.year
      errors.add(:date_of_birth, t('in_the_future'))
      return false
    end

    begin
      self.date_of_birth = Date.new(year, month, day)
    rescue Date::Error
      errors.add(:date_of_birth, t('blank'))
      return false
    end

    return false if invalid?

    trn_request.update!(date_of_birth: date_of_birth)
  end

  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def t(str)
    I18n.t("activemodel.errors.models.date_of_birth_form.attributes.date_of_birth.#{str}")
  end
end
