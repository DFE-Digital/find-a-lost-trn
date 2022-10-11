require "rails_helper"

RSpec.describe "PUT update a TRN" do
  include IdentityAuthServiceHelper

  context "with a valid TRN" do
    let(:uuid) { SecureRandom.uuid }

    before { authenticate_staff_with_mock_identity_provider }
    after { reset_mock_identity_provider_authentication }

    it "stores the TRN in the current session" do
      put "/support/identity/users/#{uuid}",
          params: {
            support_interface_trn_form: {
              trn: "7654321",
            },
          }

      expect(session[:support_interface_trn_form_trn]).to eq("7654321")
    end

    it "redirects to the edit DQT record path" do
      put "/support/identity/users/#{uuid}",
          params: {
            support_interface_trn_form: {
              trn: "7654321",
            },
          }

      expect(response).to redirect_to(
        edit_support_interface_dqt_record_path(id: uuid),
      )
    end
  end
end
