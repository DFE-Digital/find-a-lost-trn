require "rails_helper"

RSpec.describe "PUT /support/identity/change-name/:uuid" do
  include IdentityAuthServiceHelper

  before { authenticate_staff_with_mock_identity_provider }
  after { reset_mock_identity_provider_authentication }
  let(:uuid) { SecureRandom.uuid }

  context "with an invalid first name and last name" do
    let(:first_name) { "" }
    let(:last_name) { "" }
    let(:user) do
      User.new(
        "userId" => uuid,
        "first_name" => "Keanu",
        "last_name" => "Greeves",
        "created" => "2022-10-10T15:01:22.692023Z",
      )
    end
    let(:identity_users_api) do
      instance_double(IdentityUsersApi, get_user: user, update_user: user)
    end

    before do
      allow(IdentityUsersApi).to receive(:new).and_return(identity_users_api)
    end

    it "responds with a validation error" do
      put support_interface_change_name_path(uuid),
          params: {
            id: uuid,
            support_interface_change_name_form: {
              first_name:,
              last_name:,
            },
          }

      expect(response).not_to be_successful
      expect(response.body).to match(/Enter a first name/)
    end
  end

  context "with a valid first name and last name" do
    let(:first_name) { "Keanu" }
    let(:last_name) { "Greeves" }
    let(:user) do
      User.new(
        "userId" => uuid,
        "first_name" => first_name,
        "last_name" => last_name,
        "created" => "2022-10-10T15:01:22.692023Z",
      )
    end
    let(:identity_users_api) do
      instance_double(IdentityUsersApi, get_user: user, update_user: user)
    end

    before do
      allow(IdentityUsersApi).to receive(:new).and_return(identity_users_api)
    end

    it "redirects to the user page" do
      put support_interface_change_name_path(uuid),
          params: {
            id: uuid,
            support_interface_change_name_form: {
              first_name:,
              last_name:,
            },
          }

      expect(response).to redirect_to(
        support_interface_identity_user_path(uuid),
      )
    end
  end
end
