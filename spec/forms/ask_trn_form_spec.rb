# frozen_string_literal: true
require "rails_helper"

RSpec.describe AskTrnForm, type: :model do
  it do
    is_expected.to validate_inclusion_of(:do_you_know_your_trn).in_array(
      %w[true false],
    )
  end

  describe "#update" do
    subject(:update!) { ask_trn_form.update(params) }

    let(:ask_trn_form) { described_class.new(trn_request:) }
    let(:trn_request) { TrnRequest.new }
    let(:params) { { do_you_know_your_trn:, trn_from_user: } }
    let(:do_you_know_your_trn) { "true" }
    let(:trn_from_user) { "RP99/12345" }

    it "passes validation" do
      is_expected.to be_truthy
    end
    it "updates the trn_from_user attribute on the trn_request" do
      expect { update! }.to change(trn_request, :trn_from_user).from(nil).to(
        "9912345",
      )
    end

    context "when no option is selected" do
      let(:params) { { trn_from_user: } }
      let(:trn_from_user) { "" }

      it "fails validation" do
        is_expected.to be_falsy
      end
      it "adds an error" do
        update!
        expect(ask_trn_form.errors[:do_you_know_your_trn]).to eq(
          ["Tell us if you know your TRN number"],
        )
      end
      it "logs a validation error" do
        expect { update! }.to change(ValidationError, :count).by(1)
      end
    end

    context "when I want to continue without my TRN" do
      let(:do_you_know_your_trn) { "false" }
      it "passes validation" do
        is_expected.to be_truthy
      end
    end

    context "when I know my TRN but submit an empty input" do
      let(:trn_from_user) { "" }
      it "fails validation" do
        is_expected.to be_falsy
      end
      it "adds an error" do
        update!
        expect(ask_trn_form.errors[:trn_from_user]).to include("Enter your TRN")
      end
      it "logs a validation error" do
        expect { update! }.to change(ValidationError, :count).by(1)
      end
    end

    context "when I know my TRN and submit a TRN less than 7 digits" do
      let(:trn_from_user) { "RP99/123" }
      it "fails validation" do
        is_expected.to be_falsy
      end
      it "adds an error" do
        update!
        expect(ask_trn_form.errors[:trn_from_user]).to eq(
          ["Your TRN number should contain 7 digits"],
        )
      end
      it "logs a validation error" do
        expect { update! }.to change(ValidationError, :count).by(1)
      end
    end

    context "when I know my TRN and submit a TRN more than 7 digits" do
      let(:trn_from_user) { "RP99/123456" }
      it "fails validation" do
        is_expected.to be_falsy
      end
      it "adds an error" do
        update!
        expect(ask_trn_form.errors[:trn_from_user]).to eq(
          ["Your TRN number should contain 7 digits"],
        )
      end
      it "logs a validation error" do
        expect { update! }.to change(ValidationError, :count).by(1)
      end
    end

    context "when I know my TRN and it includes non numeric characters" do
      let(:trn_from_user) { "RP/99-123-67" }
      it "passes validation" do
        is_expected.to be_truthy
      end
      it "strips all non numeric characters from the TRN" do
        expect { update! }.to change(trn_request, :trn_from_user).from(nil).to(
          "9912367",
        )
      end
    end
  end
end
