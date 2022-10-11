module IdentityAuthServiceHelper
  def authenticate_staff_with_mock_identity_provider
    staff = FactoryBot.create(:staff)
    FeatureFlag.activate(:service_open)
    FeatureFlag.activate(:identity_auth_service)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:identity] = OmniAuth::AuthHash.new(
      {
        provider: "identity",
        extra: {
          raw_info: {
            email: staff.email,
          },
        },
        credentials: {
          token: {
            access_token: token_for_mock_identity_authentication,
            expires_at: 2.minutes.from_now.to_i,
          },
        },
      },
    )

    get staff_identity_omniauth_callback_path
  end

  def token_for_mock_identity_authentication
    @token_for_mock_identity_authentication ||= SecureRandom.hex
  end

  def reset_mock_identity_provider_authentication
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:identity] = nil
  end
end
