# frozen_string_literal: true
require "rails_helper"

RSpec.describe NiNumberForm, type: :model do
  subject(:ni_number_form) { described_class.new(trn_request:) }

  let(:trn_request) { TrnRequest.new }

  specify do
    expect(ni_number_form).to validate_presence_of(:ni_number).with_message(
      "Enter a National Insurance number"
    )
  end

  shared_examples "an invalid ni_number" do
    it { is_expected.to be_invalid }

    it "adds an incorrect format error message" do
      ni_number_form.validate
      expect(ni_number_form.errors[:ni_number]).to include(
        "Enter a National Insurance number in the correct format"
      )
    end
  end

  context "when the ni_number is too short" do
    before { ni_number_form.ni_number = "QQ12345C" }

    it_behaves_like "an invalid ni_number"
  end

  context "when the ni_number is missing 2 letters at the start" do
    before { ni_number_form.ni_number = "Q1234567C" }

    it_behaves_like "an invalid ni_number"
  end

  context "when the ni_number is missing a letter at the end" do
    before { ni_number_form.ni_number = "QQ1234567" }

    it_behaves_like "an invalid ni_number"
  end

  context "when the ni_number has a letter at the end out of the range" do
    before { ni_number_form.ni_number = "QQ123456E" }

    it_behaves_like "an invalid ni_number"
  end

  context "when the ni_number is too long" do
    before { ni_number_form.ni_number = "QQ1234567C" }

    it_behaves_like "an invalid ni_number"
  end

  context "when the ni_number is blank" do
    before { ni_number_form.ni_number = "" }

    it_behaves_like "an invalid ni_number"
  end

  context "when the ni_number has the correct characters but in a strange format" do
    valid_numbers_in_strange_formats = [
      "QQ 12 34 56 C",
      " QQ 12 34 56 C",
      "QQ12 34 56 C ",
      "QQ 1234 56 C",
      "QQ 12 3456 C",
      "QQ 12 34 56C",
      "QQ1234 56 C",
      "QQ 123456 C",
      "QQ 12 3456C",
      "QQ123456C",
      "QQ 1 2 3 4 5 6 C",
      "qq123456c",
      "QQ-12-34-56-C"
    ]

    valid_numbers_in_strange_formats.each do |ni_number|
      specify do
        ni_number_form.ni_number = ni_number
        expect(ni_number_form).to be_valid
      end
    end
  end

  describe "#update" do
    subject(:update) { ni_number_form.update(ni_number:) }

    context "when the ni_number is invalid" do
      let(:ni_number) { "" }

      it "logs a validation error" do
        FeatureFlag.activate(:log_validation_errors)
        expect { update }.to change(ValidationError, :count).by(1)
        FeatureFlag.deactivate(:log_validation_errors)
      end
    end
  end
end
