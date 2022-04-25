# frozen_string_literal: true
class DateOfBirthForm
  include ActiveModel::Model
  include LogErrors

  attr_accessor :trn_request
  attr_writer :date_of_birth

  validates :date_of_birth, presence: true

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
      log_errors
      return false
    end

    if day.zero?
      errors.add(:date_of_birth, t('missing_day'))
      log_errors
      return false
    end

    month = Date.parse(date_fields[1]).month if month.zero? && date_fields[1].length.positive?

    if month.zero?
      errors.add(:date_of_birth, t('missing_month'))
      log_errors
      return false
    end

    if year < 1000
      errors.add(:date_of_birth, t('missing_year'))
      log_errors
      return false
    end

    if year < 1900
      errors.add(:date_of_birth, t('born_after_1900'))
      log_errors
      return false
    end

    if year > Time.zone.today.year
      errors.add(:date_of_birth, t('in_the_future'))
      log_errors
      return false
    end

    begin
      self.date_of_birth = Date.new(year, month, day)
    rescue Date::Error
      errors.add(:date_of_birth, t('blank'))
      log_errors
      return false
    end

    if date_of_birth > 16.years.ago
      errors.add(:date_of_birth, t('inclusion'))
      log_errors
      return false
    end

    if invalid?
      log_errors
      return false
    end

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
