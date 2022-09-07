# frozen_string_literal: true
class AwardedQtsForm
  include ActiveModel::Model

  attr_accessor :trn_request

  validates :awarded_qts, inclusion: { in: [true, false] }

  delegate :awarded_qts, :awarded_qts=, to: :trn_request, allow_nil: true

  def update(params = {})
    self.awarded_qts = params[:awarded_qts]
    clear_itt_provider unless awarded_qts
    return false if invalid?

    trn_request.save!
  end

  private

  def clear_itt_provider
    trn_request.itt_provider_enrolled = nil
    trn_request.itt_provider_name = nil
    trn_request.itt_provider_ukprn = nil
  end
end
