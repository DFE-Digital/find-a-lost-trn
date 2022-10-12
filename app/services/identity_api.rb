# frozen_string_literal: true
class IdentityApi
  class ApiError < StandardError
  end

  FIVE_SECONDS = 5

  def self.submit_trn!(trn_request, journey_id)
    if FeatureFlag.active?(:identity_api_always_timeout)
      raise Faraday::TimeoutError, "Time-out feature flag enabled"
    end

    response =
      new.client.put(
        "/api/find-trn/user/#{journey_id}",
        trn_request_params(trn_request),
      )

    raise ApiError, response.reason_phrase unless response.status == 204

    response.body
  end

  def self.trn_request_params(trn_request)
    {
      firstName: trn_request.first_name,
      lastName: trn_request.last_name,
      trn: trn_request.trn,
      dateOfBirth: trn_request.date_of_birth&.to_date&.to_s,
      nationalInsuranceNumber: trn_request.ni_number,
    }.compact
  end

  def client
    @client ||=
      Faraday.new(
        url: ENV.fetch("IDENTITY_API_URL", nil),
        request: {
          timeout: FIVE_SECONDS,
        },
      ) do |faraday|
        faraday.request :authorization, "Bearer", access_token
        faraday.request :json
        faraday.response :json
        if faraday_log_output_enabled?
          faraday.response(
            :logger,
            nil,
            { bodies: true, headers: true },
          ) do |logger|
            logger.filter(
              /((given_name|family_name|birthdate|nino|trn)=)([^&]+)/,
              '\1[REDACTED]',
            )
          end
        end
        faraday.adapter Faraday.default_adapter
      end
  end

  def access_token
    ENV.fetch("IDENTITY_API_KEY", nil)
  end

  def faraday_log_output_enabled?
    ActiveRecord::Type::Boolean.new.cast(ENV.fetch("FARADAY_LOG_OUTPUT", true))
  end
end
