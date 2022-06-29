# frozen_string_literal: true
require "rails_helper"

RSpec.describe EmailForm, type: :model do
  subject(:email_form) { described_class.new }

  specify do
    expect(email_form).to validate_presence_of(:email).with_message(
      "Enter an email address"
    )
  end

  context "when the email is in the wrong format" do
    subject(:email_form) { described_class.new(email: "not_an_email") }

    specify do
      email_form.valid?
      expect(email_form.errors[:email]).to include(
        "Enter an email address in the correct format, like name@example.com"
      )
    end
  end

  describe "#save" do
    subject(:save!) { name_form.save }

    let(:email) { "test@example.com" }
    let(:name_form) { described_class.new(email:, trn_request:) }
    let(:trn_request) { TrnRequest.new }

    it { is_expected.to be_truthy }

    it "sets the email on the TrnRequest" do
      save!
      expect(trn_request.email).to eq("test@example.com")
    end

    context "when the email is blank" do
      let(:email) { "" }

      it { is_expected.to be_falsy }

      it "logs a validation error" do
        FeatureFlag.activate(:log_validation_errors)
        expect { save! }.to change(ValidationError, :count).by(1)
      end
    end
  end

  describe "#email" do
    subject { name_form.email }

    context "when the email is set on TrnRequest" do
      let(:name_form) { described_class.new(trn_request:) }
      let(:trn_request) { TrnRequest.new(email: "test@example.com") }

      it { is_expected.to eq("test@example.com") }
    end

    context "when initialized with an email address" do
      let(:name_form) do
        described_class.new(email: "new@example.com", trn_request:)
      end
      let(:trn_request) { TrnRequest.new(email: "old@example.com") }

      it { is_expected.to eq("new@example.com") }
    end
  end
end
