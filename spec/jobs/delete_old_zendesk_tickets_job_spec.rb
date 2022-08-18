require "rails_helper"

RSpec.describe DeleteOldZendeskTicketsJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    before do
      allow(ZendeskService).to receive(
        :find_closed_tickets_from_6_months_ago
      ).and_return(
        [
          ZendeskAPI::Ticket.new(
            GDS_ZENDESK_CLIENT,
            id: 42,
            custom_fields: [
              { id: 4_419_328_659_089, value: "Foo" },
              { id: 4_562_126_876_049, value: "Bar" }
            ],
            group: {
              name: "Some group"
            },
            created_at: 6.months.ago + 7.days,
            updated_at: 6.months.ago + 1.day
          ),
          ZendeskAPI::Ticket.new(
            GDS_ZENDESK_CLIENT,
            id: 13,
            custom_fields: [
              { id: 4_419_328_659_089, value: "Foo" },
              { id: 4_562_126_876_049, value: "Bar" }
            ],
            group: {
              name: "Some other group"
            },
            created_at: 6.months.ago + 8.days,
            updated_at: 6.months.ago + 2.days
          )
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

    it "creates deleted ticket entries" do
      expect { perform }.to change { ZendeskDeleteRequest.count }.by 2
    end
  end
end
