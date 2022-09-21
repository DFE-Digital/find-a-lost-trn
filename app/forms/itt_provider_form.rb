# frozen_string_literal: true
class IttProviderForm
  include ActiveModel::Model
  include LogErrors

  attr_accessor :trn_request, :itt_provider_enrolled, :itt_provider_name

  validates :itt_provider_enrolled, inclusion: { in: %w[true false] }
  validates :itt_provider_name,
            presence: true,
            length: {
              maximum: 255,
            },
            if: -> { itt_provider_enrolled == "true" }

  def itt_provider
    @itt_provider ||=
      self.class.itt_providers.find do |itt_provider_option|
        itt_provider_option.name.upcase == itt_provider_name.upcase
      end
  end

  def itt_provider_ukprn
    @itt_provider_ukprn ||=
      itt_provider && itt_provider.value.present? ? itt_provider.value : nil
  end

  def update_trn_request!
    trn_request.update!(
      itt_provider_enrolled:,
      itt_provider_name:,
      itt_provider_ukprn:,
    )
  end

  def save
    if invalid?
      log_errors
      return false
    end

    update_trn_request!
  end

  def assign_form_values
    self.itt_provider_enrolled = trn_request.itt_provider_enrolled
    self.itt_provider_name = trn_request.itt_provider_name
    self
  end

  def self.itt_providers
    Rails
      .cache
      .fetch("itt_provider_options", expires_in: 1.hour) do
        DqtApi.get_itt_providers.map do |itt_provider|
          OpenStruct.new(
            name: itt_provider["providerName"],
            value: itt_provider["ukprn"],
          )
        end
      end
  rescue DqtApi::ApiError, Faraday::ConnectionFailed, Faraday::TimeoutError => e
    Sentry.capture_exception(e)
    []
  end
end
