require "rails_helper"

RSpec.describe "Identity callback when the email is already linked to another uid",
               type: :request do
  let(:incoming_uid) { "incoming-uid" }
  let!(:existing_staff) do
    FactoryBot.create(
      :staff,
      email: "clash@example.com",
      uid: "existing-uid",
      provider: "identity",
    )
  end

  before do
    FeatureFlag.activate(:service_open)
    FeatureFlag.activate(:identity_auth_service)
    FeatureFlag.deactivate(:staff_http_basic_auth)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:identity] = OmniAuth::AuthHash.new(
      {
        provider: "identity",
        uid: incoming_uid,
        info: {
          email: existing_staff.email,
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

  it "reports the conflict to Sentry with both uids and no PII" do
    get staff_identity_omniauth_callback_path

    expect(Sentry).to have_received(:capture_exception).with(
      an_instance_of(Staff::IdentityEmailConflictError),
      contexts: {
        identity: { uid: incoming_uid, existing_staff_uid: "existing-uid" },
      },
    )
  end

  it "redirects to the sign-in page with a legible alert" do
    get staff_identity_omniauth_callback_path

    expect(response).to redirect_to(new_staff_session_path)
    expect(flash[:alert]).to include("already linked to a different sign-in")
  end

  it "does not create or mutate a Staff record" do
    expect { get staff_identity_omniauth_callback_path }
      .not_to change(Staff, :count)
    expect(existing_staff.reload.uid).to eq("existing-uid")
  end
end
