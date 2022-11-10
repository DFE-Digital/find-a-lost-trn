# frozen_string_literal: true
require "rails_helper"
require "webmock/rspec"

RSpec.describe IdentityApi do
  describe ".submit_trn!" do
    subject(:submit_trn!) do
      described_class.submit_trn!(
        trn_request,
        "9ddccb62-ec13-4ea7-a163-c058a19b8222",
      )
    end

    let(:trn_request) do
      TrnRequest.new(
        date_of_birth: "1990-01-01",
        email: "kevin.e@example.com",
        first_name: "kevin",
        last_name: "E",
        ni_number: "AA123456A",
        trn: "2921020",
      )
    end

    context "with a TRN request", vcr: true do
      it { is_expected.to eq("") }
    end

    context "when the API returns a timeout error" do
      before { FeatureFlag.activate(:identity_api_always_timeout) }

      after { FeatureFlag.deactivate(:identity_api_always_timeout) }

      it "raises a timeout error" do
        VCR.turned_off do
          expect { submit_trn! }.to raise_error(Faraday::TimeoutError)
        end
      end
    end
  end

  describe ".trn_request_params" do
    context "when there is a NI number on the trn request" do
      let(:trn_request) do
        TrnRequest.new(
          first_name: "John",
          last_name: "Smith",
          date_of_birth: Time.zone.local(2000, 1, 1),
          ni_number: "QQ123456C",
          trn: "2921020",
        )
      end

      it "the params contain the NI number" do
        expect(IdentityApi.trn_request_params(trn_request)).to eq(
          {
            firstName: "John",
            lastName: "Smith",
            dateOfBirth: "2000-01-01",
            trn: "2921020",
            nationalInsuranceNumber: "QQ123456C",
          },
        )
      end
    end

    context "when there is no NI number on the trn request" do
      let(:trn_request) do
        TrnRequest.new(
          first_name: "John",
          last_name: "Smith",
          date_of_birth: Time.zone.local(2000, 1, 1),
          trn: "2921020",
        )
      end

      it "the params do not contain the NI number" do
        expect(IdentityApi.trn_request_params(trn_request)).to eq(
          {
            firstName: "John",
            lastName: "Smith",
            dateOfBirth: "2000-01-01",
            trn: "2921020",
          },
        )
      end
    end

    context "when there is a preferred name on the trn request" do
      let(:trn_request) do
        TrnRequest.new(
          preferred_first_name: "Preferred",
          preferred_last_name: "Name",
          first_name: "John",
          last_name: "Smith",
          date_of_birth: Time.zone.local(2000, 1, 1),
          trn: "2921020",
        )
      end

      it "the params contain the preferred name" do
        expect(IdentityApi.trn_request_params(trn_request)).to eq(
          {
            firstName: "John",
            lastName: "Smith",
            preferredFirstName: "Preferred",
            preferredLastName: "Name",
            dateOfBirth: "2000-01-01",
            trn: "2921020",
          },
        )
      end
    end
  end
end
