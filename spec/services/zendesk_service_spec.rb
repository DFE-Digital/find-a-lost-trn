# frozen_string_literal: true
require "rails_helper"

RSpec.describe ZendeskService do
  let(:ticket_client) { GDS_ZENDESK_CLIENT.ticket }

  describe ".ticket_template" do
    it "correctly formats a TRN request with no NI number" do
      trn_request = TrnRequest.new(date_of_birth: 20.years.ago)

      expect(
        described_class.ticket_template(trn_request)[:comment][:value]
      ).to include("NI number: Not provided")
    end

    it "correctly formats a TRN request with no ITT provider" do
      trn_request = TrnRequest.new(date_of_birth: 20.years.ago)

      expect(
        described_class.ticket_template(trn_request)[:comment][:value]
      ).to include("ITT provider: Not provided")
    end
  end

  context "when feature flag is off" do
    before { FeatureFlag.deactivate(:zendesk_integration) }

    describe ".create_ticket!" do
      it "does not create a ticket" do
        allow(ticket_client).to receive(:create!)
        trn_request = TrnRequest.new

        expect { described_class.create_ticket!(trn_request) }.to raise_error(
          ZendeskService::ZendeskOffError
        )
        expect(ticket_client).not_to have_received(:create!)
      end
    end
  end

  context "when feature flag is on" do
    before { FeatureFlag.activate(:zendesk_integration) }
    after { FeatureFlag.deactivate(:zendesk_integration) }

    describe ".create_ticket!" do
      subject(:create_ticket!) { described_class.create_ticket!(trn_request) }

      let(:trn_request) do
        build(
          :trn_request,
          date_of_birth: 20.years.ago,
          email: "test@example.com",
          first_name: "Test",
          has_ni_number: true,
          itt_provider_enrolled: true,
          itt_provider_name: "Big SCITT",
          last_name: "User",
          ni_number: "QC123456A",
          previous_last_name: "Smith"
        )
      end

      it "creates a ticket" do
        allow(ticket_client).to receive(:create!).and_return(
          ZendeskAPI::Ticket.new(GDS_ZENDESK_CLIENT, id: 42)
        )

        create_ticket!

        expect(ticket_client).to have_received(:create!).once.with(
          {
            subject: "[Find a lost TRN] Support request from Test User",
            comment: {
              value:
                "A user has submitted a request to find their lost " \
                  "TRN. Their information is:\n" \
                  "\nName: Test User" \
                  "\nEmail: test@example.com" \
                  "\nPrevious name: Test Smith" \
                  "\nDate of birth: #{20.years.ago.strftime("%d %B %Y")}" \
                  "\nNI number: QC123456A" \
                  "\nITT provider: Big SCITT\n"
            },
            requester: {
              email: "test@example.com",
              name: "Test User"
            },
            custom_fields: {
              id: "4419328659089",
              value: "request_from_find_a_lost_trn_app"
            }
          }
        )
        expect(trn_request.zendesk_ticket_id).to eq(42)
      end

      context "with a TRN Request that breaks Zendesk" do
        let(:trn_request) do
          build(:trn_request, :has_itt_provider, first_name: "break_zendesk")
        end

        it "throws an error when it fails to create a ticket" do
          expect(Sentry).to receive(:capture_exception)
          expect { create_ticket! }.to raise_error(ZendeskService::CreateError)
        end
      end
    end

    describe ".find_ticket" do
      subject(:find_ticket) { described_class.find_ticket(ticket_id) }

      let(:ticket_id) { 42 }

      before do
        allow(ticket_client).to receive(:find).and_return(
          ZendeskAPI::Ticket.new(GDS_ZENDESK_CLIENT, id: 42)
        )
      end

      it { is_expected.to be_a(ZendeskAPI::Ticket) }
    end
  end
end
