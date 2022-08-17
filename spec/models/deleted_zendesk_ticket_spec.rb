require "rails_helper"

RSpec.describe DeletedZendeskTicket, type: :model do
  subject(:deleted_zendesk_ticket) { described_class.new }

  describe "#from" do
    before { subject.from(ticket) }

    let(:ticket) do
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
      )
    end

    it "sets ticket id" do
      expect(subject.ticket_id).to eq 42
    end

    it "sets received_at" do
      expect(subject.received_at).to be_within(1.second).of ticket.created_at
    end

    it "sets closed_at" do
      expect(subject.closed_at).to be_within(1.second).of ticket.updated_at
    end

    it "sets enquiry_type" do
      expect(subject.enquiry_type).to eq "Foo"
    end

    it "sets no_action_required" do
      expect(subject.no_action_required).to eq "Bar"
    end

    it "sets group_name" do
      expect(subject.group_name).to eq "Some group"
    end
  end
end
