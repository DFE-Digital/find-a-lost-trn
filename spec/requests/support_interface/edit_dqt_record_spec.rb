require "rails_helper"

RSpec.describe "GET edit DQT record", type: :request do
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
  let(:identity_users_api) { instance_double(IdentityUsersApi, get_user: user) }

  before do
    authenticate_staff_with_mock_identity_provider
    allow(IdentityUsersApi).to receive(:new).and_return(identity_users_api)
  end
  after { reset_mock_identity_provider_authentication }

  context "when a record exists" do
    before do
      allow(DqtApi).to receive(:find_teacher_by_trn!).and_return(
        "firstName" => "Some",
        "lastName" => "One",
        "dateOfBirth" => "2000-01-01",
      )
    end

    it "calls find_teacher_by_trn! with the TRN from the form" do
      get edit_support_interface_dqt_record_path(id: uuid, trn:)

      expect(DqtApi).to have_received(:find_teacher_by_trn!).with(trn:)
    end
  end

  context "when a record doesn't exist" do
    before do
      allow(DqtApi).to receive(:find_teacher_by_trn!).and_raise(
        DqtApi::NoResults,
      )
    end

    it "redirects to the edit user form" do
      get edit_support_interface_dqt_record_path(id: uuid, trn:)

      expect(response).to redirect_to(
        edit_support_interface_identity_user_path(uuid),
      )
    end
  end
end
