# frozen_string_literal: true
class DqtApi
  class ApiError < StandardError
  end

  class TooManyResults < StandardError
  end

  class NoResults < StandardError
  end

  TWO_SECONDS = 2

  def self.find_trn!(trn_request) # rubocop:disable Metrics/AbcSize
    raise Faraday::TimeoutError, 'Time-out feature flag enabled' if FeatureFlag.active?(:dqt_api_always_timeout)

    response = new.client.get('/v2/teachers/find', trn_request_params(trn_request))
    raise ApiError, response.reason_phrase unless response.status == 200

    results = response.body['results']
    raise TooManyResults if results.size > 1

    raise NoResults if results.size.zero?

    results.first
  end

  def self.trn_request_params(trn_request)
    {
      dateOfBirth: trn_request.date_of_birth,
      emailAddress: trn_request.email,
      firstName: trn_request.first_name,
      ittProviderName: trn_request.itt_provider_name,
      lastName: trn_request.last_name,
      previousFirstName: trn_request.previous_first_name,
      previousLastName: trn_request.previous_last_name,
      nationalInsuranceNumber: trn_request.ni_number,
    }
  end

  def client
    @client ||=
      Faraday.new(url: ENV['DQT_API_URL'], request: { timeout: TWO_SECONDS }) do |faraday|
        faraday.request :authorization, 'Bearer', ENV['DQT_API_KEY']
        faraday.request :json
        faraday.response :json
        faraday.response :logger, nil, { bodies: true, headers: true } do |logger|
          logger.filter(
            /((emailAddress|firstName|lastName|nationalInsuranceNumber|previousFirstName|previousLastName)=)([^&]+)/,
            '\1[REDACTED]',
          )
        end
        faraday.adapter Faraday.default_adapter
      end
  end
end
