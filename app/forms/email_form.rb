# frozen_string_literal: true
class EmailForm
  include ActiveModel::Model
  include LogErrors

  attr_accessor :trn_request
  attr_writer :email

  validates :email, presence: true, valid_for_notify: { if: :email }

  delegate :email?, to: :trn_request, allow_nil: true

  def email
    @email ||= trn_request&.email
  end

  def save
    if invalid?
      log_errors
      return false
    end

    trn_request.email = email
    trn_request.save!
  end
end
