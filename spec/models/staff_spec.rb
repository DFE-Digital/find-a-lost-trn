# == Schema Information
#
# Table name: staff
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  invited_by_type        :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :bigint
#
# Indexes
#
#  index_staff_on_confirmation_token    (confirmation_token) UNIQUE
#  index_staff_on_email                 (email) UNIQUE
#  index_staff_on_invitation_token      (invitation_token) UNIQUE
#  index_staff_on_invited_by            (invited_by_type,invited_by_id)
#  index_staff_on_invited_by_id         (invited_by_id)
#  index_staff_on_reset_password_token  (reset_password_token) UNIQUE
#  index_staff_on_unlock_token          (unlock_token) UNIQUE
#
require "rails_helper"

RSpec.describe Staff, type: :model do
  describe ".from_identity" do
    subject(:from_identity) { described_class.from_identity(auth_hash) }

    context "when the Staff does not exist" do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: "identity",
          extra: {
            raw_info: {
              email: "new@example.com",
            },
          },
        )
      end

      it "creates a new Staff" do
        expect { from_identity }.to change { Staff.count }.by(1)
      end

      it "marks the Staff as confirmed" do
        from_identity
        expect(Staff.last).to be_confirmed
      end
    end

    context "when the Staff email already exists" do
      let!(:existing) { create(:staff, email: "existing@example.com") }
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: "identity",
          extra: {
            raw_info: {
              email: "existing@example.com",
            },
          },
        )
      end

      it "returns the existing Staff record" do
        expect(from_identity).to eq(existing)
      end

      it "does not create a new Staff" do
        expect { from_identity }.not_to change(Staff, :count)
      end
    end
  end
end
