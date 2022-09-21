# frozen_string_literal: true
require "rails_helper"

RSpec.describe NameForm, type: :model do
  it do
    is_expected.to validate_presence_of(:first_name).with_message(
      "Enter your first name",
    )
  end
  it do
    is_expected.to validate_presence_of(:last_name).with_message(
      "Enter your last name",
    )
  end
  it { is_expected.to validate_length_of(:first_name).is_at_most(255) }
  it { is_expected.to validate_length_of(:last_name).is_at_most(255) }

  describe "#save" do
    subject(:save!) { name_form.save }

    let(:last_name) { nil }
    let(:name_form) do
      described_class.new(first_name:, last_name:, trn_request:)
    end
    let(:trn_request) { TrnRequest.new }

    context "when first and last names are present" do
      let(:first_name) { "John" }
      let(:last_name) { "Doe" }

      before { name_form.instance_variable_set(:@name_changed, "false") }

      it { is_expected.to be_truthy }

      it "sets the first name on the TrnRequest" do
        save!
        expect(trn_request.first_name).to eq("John")
      end

      it "sets the last name on the TrnRequest" do
        save!
        expect(trn_request.last_name).to eq("Doe")
      end
    end

    context "when the previous names are present" do
      let(:name_form) do
        described_class.new(
          first_name: "John",
          last_name: "Doe",
          name_changed: "true",
          previous_first_name: "Jonathan",
          previous_last_name: "Smith",
          trn_request:,
        )
      end

      it "sets the previous first name on the TrnRequest" do
        save!
        expect(trn_request.previous_first_name).to eq("Jonathan")
      end

      it "sets the previous last name on the TrnRequest" do
        save!
        expect(trn_request.previous_last_name).to eq("Smith")
      end

      it "allows previous first name to be at most 255 characters" do
        previous_first_name = "a" * 256
        name_form.previous_first_name = previous_first_name
        expect(name_form).to_not be_valid
      end

      it "allows previous last name to be at most 255 characters" do
        previous_last_name = "a" * 256
        name_form.previous_last_name = previous_last_name
        expect(name_form).to_not be_valid
      end
    end

    context "when the previous names are present but name_changed is selected to 'No, I’ve not changed my name'" do
      let(:name_form) do
        described_class.new(
          first_name: "John",
          last_name: "Doe",
          name_changed: "false",
          previous_first_name: "Jonathan",
          previous_last_name: "Smith",
          trn_request:,
        )
      end

      it "clears the previous first name on the TrnRequest" do
        save!
        expect(trn_request.previous_first_name).to be_blank
      end

      it "clears the previous last name on the TrnRequest" do
        save!
        expect(trn_request.previous_last_name).to be_blank
      end
    end

    context "when the previous names are present but name_changed is selected to 'Prefer not to say'" do
      let(:name_form) do
        described_class.new(
          first_name: "John",
          last_name: "Doe",
          name_changed: "prefer",
          previous_first_name: "Jonathan",
          previous_last_name: "Smith",
          trn_request:,
        )
      end

      it "clears the previous first name on the TrnRequest" do
        save!
        expect(trn_request.previous_first_name).to be_blank
      end

      it "clears the previous last name on the TrnRequest" do
        save!
        expect(trn_request.previous_last_name).to be_blank
      end
    end

    context "when the form is invalid" do
      context "first name is invalid" do
        let(:first_name) { nil }

        it { is_expected.to be_falsy }

        it "adds an error" do
          save!
          expect(name_form.errors[:first_name]).to include(
            "Enter your first name",
          )
        end

        it "logs a validation error" do
          expect { save! }.to change(ValidationError, :count).by(1)
        end

        it "records all the validation error messages" do
          save!
          expect(ValidationError.last.messages).to include(
            "first_name" => {
              "messages" => ["Enter your first name"],
              "value" => nil,
            },
            "last_name" => {
              "messages" => ["Enter your last name"],
              "value" => nil,
            },
          )
        end
      end

      context "name_changed is invalid" do
        let(:first_name) { "John" }
        let(:last_name) { "Doe" }

        before { name_form.instance_variable_set(:@name_changed, nil) }

        it { is_expected.to be_falsy }

        it "adds an error" do
          save!
          expect(name_form.errors[:name_changed]).to include(
            "Tell us if you have changed your name",
          )
        end

        it "logs a validation error" do
          expect { save! }.to change(ValidationError, :count).by(1)
        end

        it "records all the validation error messages" do
          save!
          expect(ValidationError.last.messages).to include(
            "name_changed" => {
              "messages" => ["Tell us if you have changed your name"],
              "value" => nil,
            },
          )
        end
      end
    end
  end

  describe "#first_name" do
    subject { name_form.first_name }

    let(:name_form) { described_class.new(trn_request:) }
    let(:trn_request) { TrnRequest.new(first_name: "Existing") }

    it { is_expected.to eq("Existing") }

    context "when intialized with a first name" do
      let(:name_form) { described_class.new(first_name: "New", trn_request:) }

      it { is_expected.to eq("New") }
    end
  end

  describe "#last_name" do
    subject { name_form.last_name }

    let(:name_form) { described_class.new(trn_request:) }
    let(:trn_request) { TrnRequest.new(last_name: "Existing") }

    it { is_expected.to eq("Existing") }

    context "when intialized with a last name" do
      let(:name_form) { described_class.new(last_name: "New", trn_request:) }

      it { is_expected.to eq("New") }
    end
  end

  describe "#previous_first_name" do
    subject { name_form.previous_first_name }

    let(:name_form) { described_class.new(trn_request:) }
    let(:trn_request) do
      TrnRequest.new(previous_first_name: "Existing", name_changed: true)
    end

    it { is_expected.to eq("Existing") }

    context "when intialized with a previous first name" do
      let(:name_form) do
        described_class.new(
          name_changed: "true",
          previous_first_name: "New",
          trn_request:,
        )
      end

      it { is_expected.to eq("New") }
    end
  end

  describe "#previous_last_name" do
    subject { name_form.previous_last_name }

    let(:name_form) { described_class.new(trn_request:) }
    let(:trn_request) do
      TrnRequest.new(previous_last_name: "Existing", name_changed: true)
    end

    it { is_expected.to eq("Existing") }

    context "when intialized with a previous last name" do
      let(:name_form) do
        described_class.new(
          name_changed: "true",
          previous_last_name: "New",
          trn_request:,
        )
      end

      it { is_expected.to eq("New") }
    end
  end
end
