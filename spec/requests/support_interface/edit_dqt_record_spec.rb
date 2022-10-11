require "rails_helper"

RSpec.describe "GET edit DQT record", type: :request do
  include IdentityAuthServiceHelper

  context "with a TRN stored in session" do
    let(:uuid) { SecureRandom.uuid }
    let(:trn) { token_for_mock_identity_authentication }
    let(:identity_users_api) do
      instance_double(
        IdentityUsersApi,
        get_user:
          User.new("userId" => uuid, "email" => "someone@somewhere.com"),
      )
    end
    let(:mock_session) do
      instance_double(
        ActionDispatch::Request::Session,
        enabled?: true,
        key?: true,
        loaded?: true,
      )
    end
    before do
      authenticate_staff_with_mock_identity_provider
      allow(IdentityUsersApi).to receive(:new).and_return(identity_users_api)
      allow(DqtApi).to receive(:find_teacher_by_trn!).and_return(
        "firstName" => "Some",
        "lastName" => "One",
        "dateOfBirth" => "2000-01-01",
      )
      allow_any_instance_of(ActionDispatch::Request).to receive(
        :session,
      ).and_return(mock_session)
      allow(mock_session).to receive(:[])
      allow(mock_session).to receive(:[]=)
      allow(mock_session).to receive(:[]).with(
        :support_interface_trn_form_trn,
      ).and_return(trn)
      allow(mock_session).to receive(:[]).with(
        :identity_users_api_access_token,
      ).and_return(
        {
          "access_token" => token_for_mock_identity_authentication,
          "expires_at" => 2.minutes.from_now,
        },
      )
      allow(mock_session).to receive(:delete)
    end

    after { reset_mock_identity_provider_authentication }

    it "calls find_teacher_by_trn! with the TRN from the current session" do
      get edit_support_interface_dqt_record_path(id: uuid)

      expect(DqtApi).to have_received(:find_teacher_by_trn!).with(trn:)
    end

    it "deletes the TRN from the session" do
      get edit_support_interface_dqt_record_path(id: uuid)

      expect(mock_session).to have_received(:delete).with(
        :support_interface_trn_form_trn,
      )
    end
  end
end
