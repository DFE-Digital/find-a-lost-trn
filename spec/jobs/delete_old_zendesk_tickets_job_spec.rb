require "rails_helper"

RSpec.describe DeleteOldZendeskTicketsJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    let(:tickets) do
      [
        ZendeskAPI::Ticket.new(
          GDS_ZENDESK_CLIENT,
          id: 42,
          custom_fields: [
            { id: 4_419_328_659_089, value: "Foo" },
            { id: 4_562_126_876_049, value: "Bar" },
          ],
          group: {
            name: "Some group",
          },
          created_at: 6.months.ago + 7.days,
          updated_at: 6.months.ago + 1.day,
        ),
        ZendeskAPI::Ticket.new(
          GDS_ZENDESK_CLIENT,
          id: 13,
          custom_fields: [
            { id: 4_419_328_659_089, value: "Foo" },
            { id: 4_562_126_876_049, value: "Bar" },
          ],
          group: {
            name: "Some other group",
          },
          created_at: 6.months.ago + 8.days,
          updated_at: 6.months.ago + 2.days,
        ),
      ]
    end

    let(:returned_tickets) { tickets }

    before do
      allow(ZendeskService).to receive(
        :find_closed_tickets_from_6_months_ago,
      ).and_return(returned_tickets)
      allow(ZendeskService).to receive(:destroy_tickets!)
    end

    context "when run in a production environment" do
      before do
        allow(HostingEnvironment).to receive(:production?).and_return(true)
      end

      it "fetches closed tickets" do
        expect(ZendeskService).to receive(
          :find_closed_tickets_from_6_months_ago,
        )
        perform
      end

      it "deletes old tickets" do
        expect(ZendeskService).to receive(:destroy_tickets!).with([42, 13])
        perform
      end

      it "creates deleted ticket entries" do
        expect { perform }.to change { ZendeskDeleteRequest.count }.by 2
      end

      context "with 100 or more tickets" do
        let(:returned_tickets) { tickets * 50 }
        it "does not raise an error" do
          expect { perform }.not_to raise_error
        end
        it "recursively performs the job" do
          perform
          expect(described_class).to have_been_enqueued
        end
      end
    end

    context "when run in a non-production environment" do
      before do
        allow(HostingEnvironment).to receive(:production?).and_return(false)
      end

      it "does not fetch closed tickets" do
        expect(ZendeskService).not_to receive(
          :find_closed_tickets_from_6_months_ago,
        )
        perform
      end

      it "does not delete old tickets" do
        expect(ZendeskService).not_to receive(:destroy_tickets!)
        perform
      end

      it "does not create deleted ticket entries" do
        expect { perform }.not_to change(ZendeskDeleteRequest, :count)
      end
    end
  end
end
