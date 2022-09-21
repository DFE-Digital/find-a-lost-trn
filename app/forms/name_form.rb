# frozen_string_literal: true
class NameForm
  include ActiveModel::Model
  include LogErrors

  attr_accessor :trn_request
  attr_writer :first_name,
              :last_name,
              :name_changed,
              :previous_first_name,
              :previous_last_name

  validates :first_name, presence: true, length: { maximum: 255 }
  validates :last_name, presence: true, length: { maximum: 255 }
  validates :previous_first_name, length: { maximum: 255 }
  validates :previous_last_name, length: { maximum: 255 }
  validate :name_change

  delegate :email?, :first_name, :last_name, to: :trn_request, allow_nil: true

  def first_name
    @first_name ||= trn_request&.first_name
  end

  def name_changed
    @trn_request_name_changed ||= trn_request&.name_changed

    # Do not select a radio option for name_changed if the first name and last name have not already been
    # entered and Yes or No has not already been selected. This is to avoid pre-selecting the Prefer option
    # when the form has yet to be filled in
    if @name_changed.nil? && @trn_request_name_changed.nil? &&
         first_name.blank? && last_name.blank?
      return nil
    end

    # No option has been selected after the form has been submitted
    return nil if errors.include?(:name_changed)

    # The form has been submitted, return the selected option
    return @name_changed if @name_changed.present?

    # When returning the to the form use the value of the trn record
    @trn_request_name_changed.nil? ? "prefer" : @trn_request_name_changed
  end

  def get_name_changed
    @name_changed != "prefer" ? @name_changed : nil
  end

  def previous_first_name
    return nil if @name_changed != "true" && trn_request&.name_changed.blank?

    @previous_first_name ||= trn_request&.previous_first_name
  end

  def previous_last_name
    return nil if @name_changed != "true" && trn_request&.name_changed.blank?

    @previous_last_name ||= trn_request&.previous_last_name
  end

  def last_name
    @last_name ||= trn_request&.last_name
  end

  def name_change
    return if @name_changed.present?

    errors.add(
      :name_changed,
      I18n.t(
        "activemodel.errors.models.name_form.attributes.name_changed.present",
      ),
    )
  end

  def save
    if invalid?
      log_errors
      return false
    end

    trn_request.first_name = first_name
    trn_request.last_name = last_name
    trn_request.name_changed = get_name_changed
    trn_request.previous_first_name = previous_first_name
    trn_request.previous_last_name = previous_last_name
    trn_request.save!
  end
end
