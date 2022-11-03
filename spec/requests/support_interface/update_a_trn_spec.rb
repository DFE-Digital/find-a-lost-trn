require "rails_helper"

RSpec.describe "PUT update a TRN", type: :request do
  include Capybara::RSpecMatchers
  include IdentityAuthServiceHelper

  let(:uuid) { SecureRandom.uuid }
  let(:trn) { "7654321" }
  let(:user) do
    User.new(
      "userId" => uuid,
      "email" => "someone@somewhere.com",
      "created" => "2022-10-10T15:01:22.692023Z",
      "registeredWithClientDisplayName" => "Development test client",
    )
  end

  before { authenticate_staff_with_mock_identity_provider }
  after { reset_mock_identity_provider_authentication }

  context "with a valid TRN" do
    let(:identity_users_api) do
      instance_double(IdentityUsersApi, get_user: user)
    end
    before do
      allow(IdentityUsersApi).to receive(:new).and_return(identity_users_api)
      allow(DqtApi).to receive(:find_teacher_by_trn!).and_return(
        "firstName" => "Some",
        "lastName" => "One",
        "dateOfBirth" => "2000-01-01",
      )
    end

    it "renders the edit DQT record page" do
      put "/support/identity/users/#{uuid}",
          params: {
            support_interface_trn_form: {
              trn:,
            },
          }

      expect(response).to be_successful
      expect(response.body).to have_selector(
        "h2.app-govuk-summary-card__title",
        text: "Get an identity",
      )
      expect(response.body).to have_selector(
        "h2.app-govuk-summary-card__title",
        text: "DQT record",
      )
      expect(response.body).to have_selector(
        "dd.govuk-summary-list__value",
        text: "Some One",
      )
      expect(response.body).to have_selector(
        "dd.govuk-summary-list__value",
        text: "1 January 2000",
      )
    end
  end

  context "with an invalid TRN" do
    it "renders an error on the TRN form" do
      put "/support/identity/users/#{uuid}",
          params: {
            support_interface_trn_form: {
              trn: "oioi",
            },
          }

      expect(response).to be_successful
      expect(response.body).to match(
        /is the wrong length \(should be 7 characters\)/,
      )
    end
  end
end
