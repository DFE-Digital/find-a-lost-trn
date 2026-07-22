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
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  uid                    :string
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
#  index_staff_on_provider_and_uid      (provider,uid) UNIQUE
#  index_staff_on_reset_password_token  (reset_password_token) UNIQUE
#  index_staff_on_unlock_token          (unlock_token) UNIQUE
#
require "rails_helper"

RSpec.describe Staff, type: :model do
  describe ".from_identity" do
    subject(:from_identity) { described_class.from_identity(auth_hash) }

    let(:uid) { "sub-uuid-123" }
    let(:email) { "new@example.com" }
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: "identity",
        uid:,
        info: { email: },
      )
    end

    context "when no Staff matches the uid or email" do
      it "creates a new Staff with the uid, provider and email" do
        expect { from_identity }.to change(Staff, :count).by(1)
        expect(Staff.last).to have_attributes(uid:, provider: "identity", email:)
      end

      it "marks the Staff as confirmed" do
        from_identity
        expect(Staff.last).to be_confirmed
      end
    end

    context "when a Staff already has the uid and provider" do
      let!(:existing) do
        create(:staff, uid:, provider: "identity", email: "old@example.com")
      end

      it "returns the existing Staff, not a new record" do
        expect { expect(from_identity).to eq(existing) }
          .not_to change(Staff, :count)
      end

      it "refreshes the email from the identity payload" do
        expect(from_identity.email).to eq(email)
      end
    end

    context "when a Staff exists by email but has no uid yet (pre-cutover)" do
      let!(:existing) { create(:staff, email:, uid: nil, provider: nil) }

      it "backfills the uid and provider onto that record" do
        expect { from_identity }.not_to change(Staff, :count)
        expect(existing.reload).to have_attributes(uid:, provider: "identity")
      end
    end

    context "when the email already belongs to a Staff with a different uid" do
      let!(:existing) do
        create(:staff, email:, uid: "other-uid", provider: "identity")
      end

      it "raises IdentityEmailConflictError carrying both uids" do
        expect { from_identity }.to raise_error(
          Staff::IdentityEmailConflictError,
        ) do |error|
          expect(error.uid).to eq(uid)
          expect(error.existing_staff_uid).to eq("other-uid")
        end
      end

      it "does not create or mutate a record" do
        count_before = Staff.count

        expect { from_identity }.to raise_error(Staff::IdentityEmailConflictError)

        expect(Staff.count).to eq(count_before)
        expect(existing.reload.uid).to eq("other-uid")
      end
    end

    context "when the identity email differs only in case from a stored record" do
      let(:email) { "New@Example.com" }
      let!(:existing) do
        create(:staff, email: "new@example.com", uid: nil, provider: nil)
      end

      it "matches and backfills that record rather than duplicating it" do
        expect { from_identity }.not_to change(Staff, :count)
        expect(existing.reload).to have_attributes(uid:, provider: "identity")
      end
    end

    context "when the identity payload has no uid" do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: "identity",
          info: { email: },
        )
      end

      it "raises IdentityMissingUidError" do
        expect { from_identity }.to raise_error(Staff::IdentityMissingUidError)
      end
    end
  end
end
