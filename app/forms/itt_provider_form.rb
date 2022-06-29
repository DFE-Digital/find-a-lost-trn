# frozen_string_literal: true
class IttProviderForm
  include ActiveModel::Model
  include LogErrors

  attr_accessor :trn_request, :itt_provider_enrolled, :itt_provider_name

  validates :itt_provider_enrolled, inclusion: { in: %w[true false] }
  validates :itt_provider_name,
            presence: true,
            length: {
              maximum: 255
            },
            if: -> { itt_provider_enrolled == "true" }

  def save
    if invalid?
      log_errors
      return false
    end

    trn_request.update!(itt_provider_enrolled:, itt_provider_name:)
  end

  def assign_form_values
    self.itt_provider_enrolled = trn_request.itt_provider_enrolled
    self.itt_provider_name = trn_request.itt_provider_name
    self
  end
end
