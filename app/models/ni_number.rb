# frozen_string_literal: true
class NiNumber
  include ActiveModel::Model

  attr_accessor :trn_request_id

  validates :ni_number, format: { with: /\A[a-z]{2}[0-9]{6}[a-d]{1}\Z/i }, presence: true

  delegate :email?, :ni_number, to: :trn_request

  def ni_number=(value)
    trn_request.ni_number = value&.gsub(/\s/, '')
  end

  def update(params = {})
    self.ni_number = params[:ni_number]
    return false if invalid?

    trn_request.update(params)
  end

  private

  def trn_request
    @trn_request ||= TrnRequest.find(trn_request_id)
  end
end
