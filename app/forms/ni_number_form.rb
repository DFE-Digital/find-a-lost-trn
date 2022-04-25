# frozen_string_literal: true
class NiNumberForm
  include ActiveModel::Model
  include LogErrors

  attr_accessor :trn_request

  validates :ni_number, presence: true, format: { with: /\A[a-z]{2}[0-9]{6}[a-d]{1}\Z/i }

  delegate :email?, :ni_number, to: :trn_request

  def ni_number=(value)
    trn_request.ni_number = value&.gsub(/\s/, '')
  end

  def update(params = {})
    self.ni_number = params[:ni_number]
    if invalid?
      log_errors
      return false
    end

    trn_request.save!
  end
end
