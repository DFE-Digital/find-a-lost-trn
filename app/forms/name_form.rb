# frozen_string_literal: true
class NameForm
  include ActiveModel::Model

  attr_accessor :trn_request
  attr_writer :first_name, :previous_first_name, :previous_last_name, :last_name

  validates :first_name, presence: true, length: { maximum: 255 }
  validates :last_name, presence: true, length: { maximum: 255 }
  validates :previous_first_name, length: { maximum: 255 }
  validates :previous_last_name, length: { maximum: 255 }

  delegate :email?, :first_name, :last_name, to: :trn_request, allow_nil: true

  def first_name
    @first_name ||= trn_request&.first_name
  end

  def name_changed
    previous_first_name.present? || previous_last_name.present?
  end

  def previous_first_name
    @previous_first_name ||= trn_request&.previous_first_name
  end

  def previous_last_name
    @previous_last_name ||= trn_request&.previous_last_name
  end

  def last_name
    @last_name ||= trn_request&.last_name
  end

  def save
    return false if invalid?

    trn_request.first_name = first_name
    trn_request.last_name = last_name
    trn_request.previous_first_name = previous_first_name
    trn_request.previous_last_name = previous_last_name
    trn_request.save
  end
end
