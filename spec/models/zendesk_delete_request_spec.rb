# == Schema Information
#
# Table name: zendesk_delete_requests
#
#  id                 :bigint           not null, primary key
#  closed_at          :datetime         not null
#  enquiry_type       :string
#  group_name         :string           not null
#  no_action_required :string
#  received_at        :datetime         not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ticket_id          :integer          not null
#
require "rails_helper"

RSpec.describe ZendeskDeleteRequest, type: :model do
  subject(:deleted_zendesk_ticket) { described_class.new }

  describe "#from" do
    before { subject.from(ticket) }

    let(:ticket) do
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

  describe ".to_csv" do
    subject { described_class.to_csv }

    it "returns the attribute headers" do
      is_expected.to eq(
        "Ticket,Group Name,Received At,Closed At,Enquiry Type,No Action Required\n",
      )
    end

    context "when there is a ZendeskDeleteRequest" do
      before { create(:zendesk_delete_request) }

      it "returns the record" do
        is_expected.to include(
          "42,QTS Enquiries,#{28.weeks.ago},#{27.weeks.ago},trn,\n",
        )
      end
    end

    context "when there are duplicate ticket IDs in the ZendeskDeleteRequests" do
      before do
        create(:zendesk_delete_request)
        create(:zendesk_delete_request)
      end

      it "returns the records de-duped" do
        is_expected.to eq(
          "Ticket,Group Name,Received At,Closed At,Enquiry Type,No Action Required\n42,QTS Enquiries,#{28.weeks.ago},#{27.weeks.ago},trn,\n",
        )
      end
    end
  end
end
