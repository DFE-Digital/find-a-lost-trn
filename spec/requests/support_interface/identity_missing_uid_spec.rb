require "rails_helper"

RSpec.describe "Identity callback when the auth response has no uid",
               type: :request do
  before do
    FeatureFlag.activate(:service_open)
    FeatureFlag.activate(:identity_auth_service)
    FeatureFlag.deactivate(:staff_http_basic_auth)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:identity] = OmniAuth::AuthHash.new(
      {
        provider: "identity",
        info: {
          email: "no-uid@example.com",
        },
        credentials: {
          token: {
            access_token: "some_token",
            expires_at: 1.minute.from_now.to_i,
          },
        },
      },
    )
    allow(Sentry).to receive(:capture_exception)
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:identity] = nil
  end

  it "reports the missing uid to Sentry" do
    get staff_identity_omniauth_callback_path

    expect(Sentry).to have_received(:capture_exception).with(
      an_instance_of(Staff::IdentityMissingUidError),
    )
  end

  it "redirects to the sign-in page with a legible alert" do
    get staff_identity_omniauth_callback_path

    expect(response).to redirect_to(new_staff_session_path)
    expect(flash[:alert]).to include("problem with the sign-in service")
  end

  it "does not create a Staff record" do
    expect { get staff_identity_omniauth_callback_path }
      .not_to change(Staff, :count)
  end
end
