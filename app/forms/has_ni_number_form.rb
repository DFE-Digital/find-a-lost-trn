# frozen_string_literal: true
class HasNiNumberForm
  include ActiveModel::Model

  attr_accessor :trn_request

  validates :has_ni_number, inclusion: { in: [true, false] }

  delegate :has_ni_number, :has_ni_number=, to: :trn_request, allow_nil: true

  def update(params = {})
    self.has_ni_number = params[:has_ni_number]
    return false if invalid?

    trn_request.save!
  end
end
