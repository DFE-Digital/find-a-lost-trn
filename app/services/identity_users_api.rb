# frozen_string_literal: true
class IdentityUsersApi < IdentityApi
  attr_reader :access_token

  def initialize(access_token)
    super()
    @access_token = access_token
  end

  def get_user(uuid)
    if FeatureFlag.active?(:identity_api_always_timeout)
      raise Faraday::TimeoutError, "Time-out feature flag enabled"
    end

    response = client.get("/api/v1/users/#{uuid}")

    raise ApiError, response.reason_phrase unless response.status == 200

    User.new(response.body)
  end

  def update_user_trn(uuid, trn)
    if FeatureFlag.active?(:identity_api_always_timeout)
      raise Faraday::TimeoutError, "Time-out feature flag enabled"
    end

    response = client.put("/api/v1/users/#{uuid}/trn", { trn: })

    raise ApiError, response.reason_phrase unless response.status == 204

    response.body
  end

  def get_users
    if FeatureFlag.active?(:identity_api_always_timeout)
      raise Faraday::TimeoutError, "Time-out feature flag enabled"
    end

    response = client.get("/api/v1/teachers")

    raise ApiError, response.reason_phrase unless response.status == 200

    users = response.body.fetch("users", [])
    users.map { |user| User.new(user) }
  end
end
