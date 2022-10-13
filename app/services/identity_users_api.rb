# frozen_string_literal: true
class IdentityUsersApi < IdentityApi
  attr_reader :access_token

  def initialize(access_token)
    super()
    @access_token = access_token
  end

  def get_user(uuid)
    raise_if_timeout_feature_flag_active!

    response = client.get("/api/v1/users/#{uuid}")

    raise ApiError, response.reason_phrase unless response.status == 200

    User.new(response.body)
  end

  def update_user_trn(uuid, trn)
    raise_if_timeout_feature_flag_active!

    response = client.put("/api/v1/users/#{uuid}/trn", { trn: })

    raise ApiError, response.reason_phrase unless response.status == 204

    response.body
  end

  def get_users
    raise_if_timeout_feature_flag_active!

    response = client.get("/api/v1/teachers")

    raise ApiError, response.reason_phrase unless response.status == 200

    users = response.body.fetch("users", [])
    users.map { |user| User.new(user) }
  end

  def update_user(uuid, user_attributes)
    raise_if_timeout_feature_flag_active!

    response = client.patch("/api/v1/users/#{uuid}", user_attributes)

    raise ApiError, response.reason_phrase unless response.status == 200

    User.new(response.body)
  end

  def raise_if_timeout_feature_flag_active!
    if FeatureFlag.active?(:identity_api_always_timeout)
      raise Faraday::TimeoutError, "Time-out feature flag enabled"
    end
  end
end
