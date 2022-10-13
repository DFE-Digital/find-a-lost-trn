require "rails_helper"

RSpec.describe IdentityUsersApi do
  describe "#get_users", vcr: true do
    it "returns users from the identity api" do
      users = described_class.new(ENV["IDENTITY_USER_TOKEN"]).get_users

      expect(users.map(&:uuid)).to include(
        "29e9e624-073e-41f5-b1b3-8164ce3a5233",
      )
    end
  end

  describe "#get_user(uuid)", vcr: true do
    let(:uuid) { "29e9e624-073e-41f5-b1b3-8164ce3a5233" }

    it "returns a user from the identity api" do
      user = described_class.new(ENV["IDENTITY_USER_TOKEN"]).get_user(uuid)

      expect(user.uuid).to eq(uuid)
      expect(user.first_name).to eq("Kevin")
      expect(user.last_name).to eq("E")
    end
  end

  describe "#update_user_trn(uuid, trn)", vcr: true do
    let(:uuid) { "29e9e624-073e-41f5-b1b3-8164ce3a5233" }
    let(:trn) { "2921020" }

    it "updates the user's trn" do
      response =
        described_class.new(ENV["IDENTITY_USER_TOKEN"]).update_user_trn(
          uuid,
          trn,
        )
      expect(response).to be_empty
    end
  end

  describe "#update_user(uuid, user_attributes)", vcr: true do
    let(:uuid) { "29e9e624-073e-41f5-b1b3-8164ce3a5233" }
    let(:user_attributes) { { "email" => "kev.ine@digital.education.gov.uk" } }

    it "updates the user's details" do
      updated_user =
        described_class.new(ENV["IDENTITY_USER_TOKEN"]).update_user(
          uuid,
          user_attributes,
        )
      expect(updated_user.email).to eq("kev.ine@digital.education.gov.uk")
    end
  end
end
