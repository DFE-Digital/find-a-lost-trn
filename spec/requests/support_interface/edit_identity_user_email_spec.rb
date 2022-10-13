require "rails_helper"

RSpec.describe "PUT /users/:id/email/update" do
  include IdentityAuthServiceHelper

  before { authenticate_staff_with_mock_identity_provider }
  after { reset_mock_identity_provider_authentication }
  let(:uuid) { SecureRandom.uuid }

  context "with an invalid email" do
    let(:email) { "notanemail" }

    it "responds with a validation error" do
      put support_interface_update_identity_user_email_path(uuid),
          params: {
            id: uuid,
            support_interface_email_form: {
              email:,
            },
          }

      expect(response).to be_successful
      expect(response.body).to match(
        /Enter an email address in the correct format, like name@example.com/,
      )
    end
  end

  context "with a valid email" do
    let(:email) { "email@domain.com" }
    let(:user) { User.new("userId" => uuid, "email" => email) }
    let(:identity_users_api) do
      instance_double(IdentityUsersApi, get_user: user, update_user: user)
    end

    before do
      allow(IdentityUsersApi).to receive(:new).and_return(identity_users_api)
    end

    it "redirects to the user page" do
      put support_interface_update_identity_user_email_path(uuid),
          params: {
            id: uuid,
            support_interface_email_form: {
              email:,
            },
          }

      expect(response).to redirect_to(
        support_interface_identity_user_path(uuid),
      )
    end
  end
end
