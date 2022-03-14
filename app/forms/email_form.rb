# frozen_string_literal: true
class EmailForm
  include ActiveModel::Model

  attr_accessor :trn_request
  attr_writer :email

  validates :email, valid_for_notify: true

  delegate :email?, to: :trn_request, allow_nil: true

  def email
    @email ||= trn_request&.email
  end

  def save
    return false if invalid?

    trn_request.email = email
    trn_request.save
  end
end
