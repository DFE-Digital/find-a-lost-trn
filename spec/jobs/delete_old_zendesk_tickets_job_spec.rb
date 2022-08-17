require "rails_helper"

RSpec.describe DeleteOldZendeskTicketsJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    before do
      allow(ZendeskService).to receive(
        :find_closed_tickets_from_6_months_ago
      ).and_return(
        [
          ZendeskAPI::Ticket.new(GDS_ZENDESK_CLIENT, id: 42),
          ZendeskAPI::Ticket.new(GDS_ZENDESK_CLIENT, id: 13)
        ]
      )
      allow(ZendeskService).to receive(:destroy_tickets!)
    end

    it "fetches closed tickets" do
      expect(ZendeskService).to receive(:find_closed_tickets_from_6_months_ago)
      perform
    end

    it "deletes old tickets" do
      expect(ZendeskService).to receive(:destroy_tickets!).with([42, 13])
      perform
    end
  end
end
