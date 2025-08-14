# frozen_string_literal: true
class DqtApi
  class ApiError < StandardError
  end

  class TooManyResults < StandardError
  end

  class NoResults < StandardError
  end

  FIVE_SECONDS = 5

  def self.find_trn!(trn_request)
    if FeatureFlag.active?(:dqt_api_always_timeout)
      raise Faraday::TimeoutError, "Time-out feature flag enabled"
    end

    response =
      new.client.get("/v2/teachers/find", trn_request_params(trn_request))
    raise ApiError, response.reason_phrase unless response.status == 200

    results = response.body["results"]
    raise TooManyResults if results.size > 1

    raise NoResults if results.empty?

    results.first
  end

  def self.find_teacher!(date_of_birth:, trn:)
    response =
      new.client.get("/v1/teachers/#{trn}", { birthdate: date_of_birth })
    response.body
  end

  def self.find_teacher_by_trn!(trn:)
    response = new.client.get("/v2/teachers/#{trn}")
    raise NoResults if response.status == 404
    raise ApiError unless response.status == 200
    response.body
  end

  def self.get_itt_providers
    response = new.client.get("/v2/itt-providers", {})
    raise ApiError unless response.status == 200

    return [] unless response.body.key?("ittProviders")
    response.body["ittProviders"]
  end

  def self.trn_request_params(trn_request)
    {
      dateOfBirth: trn_request.date_of_birth&.to_date&.iso8601,
      emailAddress: trn_request.email,
      firstName: trn_request.first_name,
      ittProviderName: trn_request.itt_provider_name_for_dqt,
      ittProviderUkprn: trn_request.itt_provider_ukprn,
      lastName: trn_request.last_name,
      previousFirstName: trn_request.previous_first_name,
      previousLastName: trn_request.previous_last_name,
      nationalInsuranceNumber: trn_request.ni_number,
      trn: trn_request.trn_from_user,
    }.compact
  end

  def client
    @client ||=
      Faraday.new(
        url: ENV.fetch("DQT_API_URL", nil),
        request: {
          timeout: FIVE_SECONDS,
        },
      ) do |faraday|
        faraday.request :authorization, "Bearer", ENV.fetch("DQT_API_KEY", nil)
        faraday.request :json
        faraday.response :json
        faraday.adapter Faraday.default_adapter
      end
  end
end
