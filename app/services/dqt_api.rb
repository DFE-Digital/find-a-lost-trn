# frozen_string_literal: true
class DqtApi
  class ApiError < StandardError
  end

  class TooManyResults < StandardError
  end

  TWO_SECONDS = 2

  def self.find_trn!(trn_request)
    raise Faraday::TimeoutError, 'Time-out feature flag enabled' if FeatureFlag.active?(:dqt_api_always_timeout)

    response = new.client.get('/v2/teachers/find', trn_request_params(trn_request))
    raise ApiError, response.reason_phrase unless response.status == 200

    results = response.body['results']
    raise TooManyResults if results.size > 1

    results.first
  end

  def self.trn_request_params(trn_request)
    {
      dateOfBirth: trn_request.date_of_birth,
      emailAddress: trn_request.email,
      firstName: trn_request.first_name,
      ittProviderName: trn_request.itt_provider_name,
      lastName: trn_request.last_name,
      nationalInsuranceNumber: trn_request.ni_number,
    }
  end

  def client
    @client ||=
      Faraday.new(url: ENV['DQT_API_URL'], request: { timeout: TWO_SECONDS }) do |faraday|
        faraday.request :authorization, 'Bearer', ENV['DQT_API_KEY']
        faraday.request :json
        faraday.response :json
        faraday.adapter Faraday.default_adapter
      end
  end
end
