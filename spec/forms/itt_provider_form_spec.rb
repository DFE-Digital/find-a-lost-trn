# frozen_string_literal: true
require "rails_helper"

RSpec.describe IttProviderForm, type: :model do
  describe "validations" do
    specify do
      form = described_class.new
      expect(form).to validate_presence_of(:itt_provider_enrolled).with_message(
        "Tell us how you were awarded qualified teacher status (QTS)"
      )
    end

    specify do
      form = described_class.new(itt_provider_enrolled: "true")
      expect(form).to validate_presence_of(:itt_provider_name).with_message(
        "Enter your university, SCITT, school or other training provider"
      )
    end

    specify do
      form = described_class.new(itt_provider_enrolled: "true")
      expect(form).to validate_length_of(:itt_provider_name).is_at_most(
        255
      ).with_message("Enter a school that is less than 255 letters long")
    end
  end

  describe "#save" do
    subject(:save!) { form.save }

    context "when itt_provider_enrolled is missing" do
      let(:form) { described_class.new(trn_request: TrnRequest.new) }

      it { is_expected.to be_falsy }

      it "logs a validation error" do
        expect { save! }.to change(ValidationError, :count).by(1)
      end
    end

    context "when form data is correct" do
      let(:form) do
        described_class.new(
          trn_request: TrnRequest.new,
          itt_provider_enrolled: "true",
          itt_provider_name: "Big SCITT"
        )
      end

      it "saves the model" do
        save!
        expect(form.trn_request.itt_provider_enrolled).to be true
        expect(form.trn_request.itt_provider_name).to eq "Big SCITT"
      end
    end
  end
end
