# frozen_string_literal: true
class IdentityApi
  class ApiError < StandardError
  end

  FIVE_SECONDS = 5

  def self.get_user(uuid)
    if FeatureFlag.active?(:identity_api_always_timeout)
      raise Faraday::TimeoutError, "Time-out feature flag enabled"
    end

    response = new.client.get("/api/v1/users/#{uuid}")

    raise ApiError, response.reason_phrase unless response.status == 200

    User.new(response.body)
  end

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

  def self.update_user_trn(uuid, trn)
    if FeatureFlag.active?(:identity_api_always_timeout)
      raise Faraday::TimeoutError, "Time-out feature flag enabled"
    end

    response = new.client.put("/api/v1/users/#{uuid}/trn", { trn: })

    raise ApiError, response.reason_phrase unless response.status == 204

    response.body
  end

  def self.get_users
    if FeatureFlag.active?(:identity_api_always_timeout)
      raise Faraday::TimeoutError, "Time-out feature flag enabled"
    end

    response = new.client.get("/api/v1/teachers")

    raise ApiError, response.reason_phrase unless response.status == 200

    users = response.body.fetch("users", [])
    users.map { |user| User.new(user) }
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
        faraday.request :authorization,
                        "Bearer",
                        ENV.fetch("IDENTITY_API_KEY", nil)
        faraday.request :json
        faraday.response :json
        faraday.response :logger,
                         nil,
                         { bodies: true, headers: true } do |logger|
          logger.filter(
            /((given_name|family_name|birthdate|nino|trn)=)([^&]+)/,
            '\1[REDACTED]',
          )
        end
        faraday.adapter Faraday.default_adapter
      end
  end
end
