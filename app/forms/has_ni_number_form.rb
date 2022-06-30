# frozen_string_literal: true
class HasNiNumberForm
  include ActiveModel::Model
  include LogErrors

  attr_accessor :trn_request

  validates :has_ni_number, inclusion: { in: [true, false] }

  delegate :has_ni_number, :has_ni_number=, to: :trn_request, allow_nil: true

  def update(params = {})
    self.has_ni_number = params[:has_ni_number]
    clear_ni_number unless has_ni_number
    if invalid?
      log_errors
      return false
    end

    trn_request.save!
  end

  def clear_ni_number
    trn_request.ni_number = nil
  end
end
