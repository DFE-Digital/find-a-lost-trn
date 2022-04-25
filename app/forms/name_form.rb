# frozen_string_literal: true
class NameForm
  include ActiveModel::Model
  include LogErrors

  attr_accessor :trn_request
  attr_writer :first_name, :last_name, :name_changed, :previous_first_name, :previous_last_name

  validates :first_name, presence: true, length: { maximum: 255 }
  validates :last_name, presence: true, length: { maximum: 255 }
  validates :name_changed, absence: { if: :no_previous_names? }
  validates :previous_first_name, length: { maximum: 255 }
  validates :previous_last_name, length: { maximum: 255 }

  delegate :email?, :first_name, :last_name, to: :trn_request, allow_nil: true

  def first_name
    @first_name ||= trn_request&.first_name
  end

  def name_changed
    return @name_changed unless @name_changed.nil?

    @name_changed ||= previous_first_name.present? || previous_last_name.present?
  end

  def no_previous_names?
    previous_first_name.blank? && previous_last_name.blank?
  end

  def previous_first_name
    return nil if !@name_changed.nil? && !@name_changed

    @previous_first_name ||= trn_request&.previous_first_name
  end

  def previous_last_name
    return nil if !@name_changed.nil? && !@name_changed

    @previous_last_name ||= trn_request&.previous_last_name
  end

  def last_name
    @last_name ||= trn_request&.last_name
  end

  def save
    if invalid?
      log_errors
      return false
    end

    trn_request.first_name = first_name
    trn_request.last_name = last_name
    trn_request.previous_first_name = previous_first_name
    trn_request.previous_last_name = previous_last_name
    trn_request.save
  end
end
