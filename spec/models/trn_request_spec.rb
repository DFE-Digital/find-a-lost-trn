# frozen_string_literal: true

# == Schema Information
#
# Table name: trn_requests
#
#  id                      :bigint           not null, primary key
#  awarded_qts             :boolean
#  checked_at              :datetime
#  date_of_birth           :date
#  email                   :string(510)
#  first_name              :string(510)
#  from_get_an_identity    :boolean          default(FALSE)
#  has_active_sanctions    :boolean
#  has_ni_number           :boolean
#  itt_provider_enrolled   :boolean
#  itt_provider_name       :string
#  itt_provider_ukprn      :string
#  last_name               :string(510)
#  name_changed            :boolean
#  ni_number               :string(510)
#  official_name_preferred :boolean
#  preferred_first_name    :string
#  preferred_last_name     :string
#  previous_first_name     :string(510)
#  previous_last_name      :string(510)
#  trn                     :string
#  trn_from_user           :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  zendesk_ticket_id       :integer
#
require "rails_helper"

RSpec.describe TrnRequest, type: :model do
  subject(:trn_request) do
    described_class.new(
      email: "test@example.com",
      has_ni_number: false,
      itt_provider_enrolled: "no",
    )
  end

  it { is_expected.to be_valid }

  describe "#answers_checked=" do
    before { trn_request.answers_checked = value }

    context "when true" do
      let(:value) { true }

      it "stores the current timestamp on checked_at" do
        expect(trn_request.checked_at).to be_present
      end
    end

    context "when false" do
      let(:value) { false }

      it "does not set checked_at" do
        expect(trn_request.checked_at).to be_nil
      end
    end
  end

  describe "#name" do
    subject { trn_request.name }

    let(:trn_request) do
      described_class.new(first_name: "John", last_name: "Doe")
    end

    it { is_expected.to eq("John Doe") }

    context "when preferred name is set" do
      before { trn_request.preferred_first_name = "Jimmy" }

      it "returns the preferred name" do
        expect(subject).to eq "Jimmy"
      end
    end
  end

  describe "#previous_name?" do
    subject { trn_request.previous_name? }

    context "when a previous first name is present" do
      let(:trn_request) { described_class.new(previous_first_name: "John") }

      it { is_expected.to be_truthy }
    end

    context "when a previous last name is present" do
      let(:trn_request) { described_class.new(previous_last_name: "John") }

      it { is_expected.to be_truthy }
    end
  end

  describe "#previous_name" do
    subject { trn_request.previous_name }

    context "when a previous first name is present" do
      let(:trn_request) do
        described_class.new(
          first_name: "John",
          last_name: "Doe",
          previous_first_name: "Joan",
        )
      end

      it { is_expected.to eq("Joan Doe") }
    end

    context "when a previous last name is present" do
      let(:trn_request) do
        described_class.new(
          first_name: "John",
          last_name: "Doe",
          previous_last_name: "Smith",
        )
      end

      it { is_expected.to eq("John Smith") }
    end
  end

  describe "#previous_trn_success_for_email?" do
    subject(:trn_request) do
      described_class.create(
        first_name: "John",
        last_name: "Doe",
        previous_last_name: "Smith",
        trn: "2921020",
        email: "john.doe@example.com",
      )
    end

    context "with no previous successful trn search for email address" do
      it { expect(subject.previous_trn_success_for_email?).to be_falsey }
    end

    context "when there is no trn" do
      it do
        subject.trn = nil
        expect(subject.previous_trn_success_for_email?).to be_falsey
      end
    end

    context "when there is a previous successful trn search for the email address" do
      context "with the same trn" do
        let!(:previous_successful_trn_request) do
          described_class.create(
            first_name: "John",
            last_name: "Doe",
            previous_last_name: "Smith",
            trn: "2921020",
            email: "john.doe@example.com",
          )
        end

        it { expect(trn_request.previous_trn_success_for_email?).to be_falsey }
      end

      context "with a different trn" do
        let!(:previous_successful_trn_request) do
          described_class.create(
            first_name: "John",
            last_name: "Doe",
            previous_last_name: "Smith",
            trn: "2921019",
            email: "john.doe@example.com",
          )
        end

        it { expect(trn_request.previous_trn_success_for_email?).to be_truthy }

        context "and the current TrnRequest has no trn" do
          it do
            subject.trn = nil
            expect(subject.previous_trn_success_for_email?).to be_falsey
          end
        end
      end
    end

    context "when there is a previous no match trn search for the email address" do
      let!(:previous_successful_trn_request) do
        described_class.create(
          first_name: "John",
          last_name: "Doe",
          previous_last_name: "Smith",
          trn: nil,
          email: "john.doe@example.com",
        )
      end

      it { expect(trn_request.previous_trn_success_for_email?).to be_falsey }
    end
  end

  describe "#first_unlocked_at" do
    subject { trn_request.first_unlocked_at }

    let(:trn_request) { create(:trn_request) }

    context "when the trn request has not been unlocked" do
      it { is_expected.to be_nil }
    end

    context "when the trn request has been unlocked" do
      before { create(:account_unlock_event, trn_request:) }

      it { is_expected.to be_present }
    end

    context "when the trn request has been unlocked multiple times" do
      let(:first_unlocked_at) { 1.day.ago }

      before do
        freeze_time
        create(
          :account_unlock_event,
          trn_request:,
          created_at: first_unlocked_at,
        )
        create(:account_unlock_event, trn_request:)
      end

      after { travel_back }

      it { is_expected.to eq(first_unlocked_at) }
    end
  end
end
