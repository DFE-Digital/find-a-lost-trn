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
