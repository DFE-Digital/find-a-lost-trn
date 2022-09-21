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

  def update(params = {})
    date_fields = [
      params["date_of_birth(1i)"],
      params["date_of_birth(2i)"],
      params["date_of_birth(3i)"],
    ]

    date_fields.map! { |f| f.is_a?(String) ? f.strip : f }

    # Use a struct instead of a date object to maintain what the user typed in,
    # and not transform the fields into other data types like integers that
    # Date.new is capable of accepting.
    self.date_of_birth = Struct.new(:year, :month, :day).new(*date_fields)

    year, month, day = date_fields.map { |f| word_to_number(f) }.map(&:to_i)

    if day.zero? && month.zero? && year.zero?
      errors.add(:date_of_birth, t("blank"))
      log_errors
      return false
    end

    if day.zero?
      errors.add(:date_of_birth, t("missing_day"))
      log_errors
      return false
    end

    month_is_a_word = month.zero? && date_fields[1].length.positive?
    month = word_to_month(date_fields[1]) if month_is_a_word

    if month.zero?
      errors.add(:date_of_birth, t("missing_month"))
      log_errors
      return false
    end

    if year < 1000
      errors.add(:date_of_birth, t("missing_year"))
      log_errors
      return false
    end

    if year < 1900
      errors.add(:date_of_birth, t("born_after_1900"))
      log_errors
      return false
    end

    if year > Time.zone.today.year
      errors.add(:date_of_birth, t("in_the_future"))
      log_errors
      return false
    end

    begin
      self.date_of_birth = Date.new(year, month, day)
    rescue Date::Error
      errors.add(:date_of_birth, t("blank"))
      log_errors
      return false
    end

    if date_of_birth > 16.years.ago
      errors.add(:date_of_birth, t("inclusion"))
      log_errors
      return false
    end

    if invalid?
      log_errors
      return false
    end

    trn_request.update!(date_of_birth:)
  end

  private

  def t(str)
    I18n.t(
      "activemodel.errors.models.date_of_birth_form.attributes.date_of_birth.#{str}",
    )
  end

  def word_to_number(field)
    return field if field.is_a? Integer

    words = {
      one: 1,
      two: 2,
      three: 3,
      four: 4,
      five: 5,
      six: 6,
      seven: 7,
      eight: 8,
      nine: 9,
      ten: 10,
      eleven: 11,
      twelve: 12,
    }

    words[field.downcase.to_sym] || field
  end

  # Attempts to convert Jan, Feb, etc to month numbers. Returns 0 otherwise.
  def word_to_month(raw_month)
    begin
      month = Date.parse(raw_month).month
    rescue Date::Error
      month = 0
    end
    month
  end
end
