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
end
