# frozen_string_literal: true
require "rails_helper"

RSpec.describe ZendeskService do
  let(:ticket_client) { GDS_ZENDESK_CLIENT.ticket }
  let(:zendesk_client) { GDS_ZENDESK_CLIENT.zendesk_client }
  let(:zendesk_api_ticket) { ZendeskAPI::Ticket }

  describe ".ticket_template" do
    it "has the correct custom field values" do
      trn_request = create(:trn_request, date_of_birth: 20.years.ago )

      ticket_content = described_class.ticket_template(trn_request)

      expect(ticket_content.dig(:custom_fields, :id)).to eq("4419328659089")
      expect(ticket_content.dig(:custom_fields, :value)).to eq("request_from_find_a_lost_trn_app")
    end

    it "correctly formats a TRN request with no NI number" do
      trn_request = create(:trn_request, date_of_birth: 20.years.ago)

      expect(
        described_class.ticket_template(trn_request)[:comment][:value],
      ).to include("NI number: Not provided")
    end

    it "correctly formats a TRN request with no ITT provider" do
      trn_request = create(:trn_request, date_of_birth: 20.years.ago)

      expect(
        described_class.ticket_template(trn_request)[:comment][:value],
      ).to include("ITT provider: Not provided")
    end

    context "when TRN request is from Identity auth flow" do
      it "has the correct custom field values" do
        trn_request = create(:trn_request, :from_get_an_identity)

        ticket_content = described_class.ticket_template(trn_request)

        expect(ticket_content.dig(:custom_fields, :id)).to eq("4419328659089")
        expect(ticket_content.dig(:custom_fields, :value)).to eq("request_from_identity_auth_service")
      end

      it "includes the user-provided TRN if present" do
        trn_request = create(:trn_request, :from_get_an_identity, trn_from_user: nil)
        ticket_content = described_class.ticket_template(trn_request)
        expect(ticket_content.dig(:comment, :value)).to include("User-provided TRN: Not provided")

        trn_request = create(:trn_request, :from_get_an_identity, trn_from_user: "123ABCD")
        ticket_content = described_class.ticket_template(trn_request)
        expect(ticket_content.dig(:comment, :value)).to include("User-provided TRN: 123ABCD")
      end
    end
  end

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
        previous_last_name: "Smith",
      )
    end

    it "creates a ticket" do
      allow(ticket_client).to receive(:create!).and_return(
        ZendeskAPI::Ticket.new(GDS_ZENDESK_CLIENT, id: 42),
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
                "\nITT provider: Big SCITT\n",
          },
          requester: {
            email: "test@example.com",
            name: "Test User",
          },
          custom_fields: {
            id: "4419328659089",
            value: "request_from_find_a_lost_trn_app",
          },
        },
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
        ZendeskAPI::Ticket.new(GDS_ZENDESK_CLIENT, id: 42),
      )
    end

    it { is_expected.to be_a(ZendeskAPI::Ticket) }
  end

  describe ".find_ticket!" do
    subject(:find_ticket!) { described_class.find_ticket!(ticket_id) }

    let(:ticket_id) { 42 }

    context "when the ticket exists" do
      before do
        allow(ticket_client).to receive(:find!).and_return(
          ZendeskAPI::Ticket.new(GDS_ZENDESK_CLIENT, id: 42),
        )
      end

      it { is_expected.to be_a(ZendeskAPI::Ticket) }
    end
  end

  describe ".find_closed_tickets_from_6_months_ago" do
    subject(:find_closed_tickets) do
      described_class.find_closed_tickets_from_6_months_ago
    end

    let(:search_results) { double("ZendeskAPI::Colleciton", count: 1) }

    it { is_expected.to be_a(ZendeskAPI::Collection) }
  end

  describe ".destroy_tickets!" do
    subject(:find_closed_tickets) do
      described_class.destroy_tickets!(ids: [ticket_id_1, ticket_id_2])
    end

    let(:ticket_id_1) { 42 }
    let(:ticket_id_2) { 13 }

    before do
      allow(zendesk_api_ticket).to receive(:destroy_many!).and_return([])
    end

    it { is_expected.to be_a(Array) }
  end
end
