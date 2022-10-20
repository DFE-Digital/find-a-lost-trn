# frozen_string_literal: true
require "rails_helper"

RSpec.describe PreferredNameForm, type: :model do
  describe "#save!" do
    context "when form is invalid" do
      let(:trn_request) { create(:trn_request) }
      let(:form) { described_class.new(trn_request:) }

      it "does not save" do
        form.official_name_preferred = false
        form.save!
        expect(form).to be_invalid
        expect(trn_request.official_name_preferred).to eq nil
      end
    end

    context "when form value official_name_preferred is true" do
      let(:trn_request) { build(:trn_request) }
      let(:form) do
        described_class.new(
          trn_request:,
          official_name_preferred: "false",
          preferred_first_name: "Ray",
          preferred_last_name: "Purchase",
        )
      end

      it "persists the preferred names" do
        form.save!

        expect(trn_request.official_name_preferred).to eq false
        expect(trn_request.preferred_first_name).to eq "Ray"
        expect(trn_request.preferred_last_name).to eq "Purchase"
      end
    end


    context "when form value official_name_preferred is true" do
      let(:trn_request) { build(:trn_request) }
      let(:form) do
        described_class.new(
          trn_request:,
          official_name_preferred: "true",
          preferred_first_name: "Ray",
          preferred_last_name: "Purchase",
        )
      end

      it "does not persist the preferred names" do
        form.save!

        expect(trn_request.official_name_preferred).to eq true
        expect(trn_request.preferred_first_name).to eq nil
        expect(trn_request.preferred_last_name).to eq nil
      end
    end

    context "when changing choice" do
      let(:trn_request) do
        create(
          :trn_request,
          official_name_preferred: false,
          preferred_first_name: "Ray",
          preferred_last_name: "Purchase"
        )
      end
      let(:form) do
        described_class.new(
          trn_request:,
          official_name_preferred: "true",
        )
      end

      it "previously saved preferred names are discarded" do
        form.save!

        expect(trn_request.official_name_preferred).to eq true
        expect(trn_request.preferred_first_name).to eq nil
        expect(trn_request.preferred_last_name).to eq nil
      end
    end
  end

  describe "validations" do
    describe "#official_name_preferred" do
      it "validates return value is not blank" do
        trn_request = build(:trn_request)
        form = described_class.new(
          trn_request:,
          preferred_first_name: "Ray",
          preferred_last_name: "Purchase",
        )

        ["arbitrary_string", "false", true, false].each do |assigned_value|
          form.official_name_preferred = assigned_value
          expect(form).to be_valid
        end

        [nil, ""].each do |assigned_value|
          form.official_name_preferred = assigned_value
          expect(form).not_to be_valid
          expect(form.errors[:official_name_preferred]).to include "Tell us if this is your preferred name"
        end
      end
    end

    describe "#preferred_first_name" do
      let(:trn_request) { build(:trn_request) }
      let(:form) { described_class.new(trn_request:) }

      it "must be present if official_name_preferred is false" do
        form.official_name_preferred = true
        expect(form).to be_valid

        form.official_name_preferred = false
        expect(form).not_to be_valid
        expect(form.errors.messages[:preferred_first_name]).to include "Enter your preferred first name"
      end
    end

    describe "#preferred_last_name" do
      let(:trn_request) { build(:trn_request) }
      let(:form) { described_class.new(trn_request:) }

      it "must be present if official_name_preferred is false" do
        form.official_name_preferred = true
        expect(form).to be_valid

        form.official_name_preferred = false
        expect(form).not_to be_valid
        expect(form.errors.messages[:preferred_first_name]).to include "Enter your preferred first name"
      end
    end
  end
end
