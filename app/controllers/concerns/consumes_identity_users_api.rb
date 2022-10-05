# frozen_string_literal: true
module ConsumesIdentityUsersApi
  extend ActiveSupport::Concern

  def identity_users_api
    @identity_users_api ||=
      IdentityUsersApi.new(identity_users_api_access_token)
  end

  def identity_users_api_access_token
    if FeatureFlag.active?("identity_auth_service")
      session[:identity_users_api_access_token]
    else
      ENV.fetch("IDENTITY_USER_TOKEN", nil)
    end
  end
end
