# frozen_string_literal: true
require "rails_helper"

RSpec.describe PreferredNameForm, type: :model do
  describe "#save" do
    it "persists the preferred names" do
      trn_request = create(:trn_request)

      form =
        described_class.new(
          trn_request:,
          preferred_first_name: "Ray",
          preferred_last_name: "Purchase",
        )
      form.save!

      expect(trn_request.preferred_first_name).to eq "Ray"
      expect(trn_request.preferred_last_name).to eq "Purchase"
    end
  end
end
