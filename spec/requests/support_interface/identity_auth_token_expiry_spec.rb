require "rails_helper"

RSpec.describe "GET /support with identity_auth_service feature enabled",
               type: :request do
  let(:staff) { FactoryBot.create(:staff) }
  let(:expires_at) { 1.minute.from_now.to_i }
  before do
    FeatureFlag.activate(:service_open)
    FeatureFlag.activate(:identity_auth_service)
    FeatureFlag.deactivate(:staff_http_basic_auth)
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
            access_token: "some_token",
            expires_at:,
          },
        },
      },
    )

    get staff_identity_omniauth_callback_path
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:identity] = nil
  end

  context "with an access token which is valid" do
    let(:identity_users_api) do
      instance_double(IdentityUsersApi, get_users: [])
    end

    it "allows access to support pages" do
      allow(IdentityUsersApi).to receive(:new).with("some_token").and_return(
        identity_users_api,
      )

      get "/support/identity"

      expect(response.status).to eq(200)
    end
  end

  context "with an access token which is expired" do
    let(:expires_at) { 1.minute.ago.to_i }

    it "redirects to the sign in path" do
      get "/support/identity"

      expect(response).to redirect_to("/staff/sign_in")
    end
  end
end
