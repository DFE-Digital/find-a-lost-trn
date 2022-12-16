# == Schema Information
#
# Table name: zendesk_delete_requests
#
#  id                 :bigint           not null, primary key
#  closed_at          :datetime         not null
#  enquiry_type       :string
#  group_name         :string
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

    context "when the ticket has no group" do
      let(:ticket) do
        ZendeskAPI::Ticket.new(
          GDS_ZENDESK_CLIENT,
          id: 42,
          custom_fields: [
            { id: 4_419_328_659_089, value: "Foo" },
            { id: 4_562_126_876_049, value: "Bar" },
          ],
          group: nil,
          created_at: 6.months.ago + 7.days,
          updated_at: 6.months.ago + 1.day,
        )
      end

      it "sets group_name to nil" do
        expect(deleted_zendesk_ticket.group_name).to be_nil
      end
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
      before do
        create(
          :zendesk_delete_request,
          enquiry_type: "change_of_details",
          no_action_required: "t",
        )
      end

      let(:closed_at) do
        27.weeks.ago.in_time_zone("London").strftime("%Y-%m-%d %H:%M")
      end
      let(:received_at) do
        28.weeks.ago.in_time_zone("London").strftime("%Y-%m-%d %H:%M")
      end

      it "returns the record" do
        is_expected.to include(
          "42,QTS Enquiries,#{received_at},#{closed_at},Change Of Details,No action required",
        )
      end
    end

    context "when there are duplicate ticket IDs in the ZendeskDeleteRequests" do
      let(:closed_at) do
        27.weeks.ago.in_time_zone("London").strftime("%Y-%m-%d %H:%M")
      end
      let(:received_at) do
        28.weeks.ago.in_time_zone("London").strftime("%Y-%m-%d %H:%M")
      end

      before do
        create(:zendesk_delete_request)
        create(:zendesk_delete_request)
        create(:zendesk_delete_request)
        create(:zendesk_delete_request, ticket_id: 43)
      end

      it "returns the records de-duped" do
        is_expected.to eq(
          [
            "Ticket,Group Name,Received At,Closed At,Enquiry Type,No Action Required",
            "42,QTS Enquiries,#{received_at},#{closed_at},Trn,",
            "43,QTS Enquiries,#{received_at},#{closed_at},Trn,\n",
          ].join("\n"),
        )
      end
    end
  end

  describe ".since_launch" do
    subject { described_class.since_launch }

    let(:prelaunch) { create(:zendesk_delete_request, closed_at: 1.day.ago) }
    let(:postlaunch) do
      create(:zendesk_delete_request, closed_at: Time.current)
    end

    before do
      travel_to PerformanceStats::LAUNCH_DATE
      prelaunch
      postlaunch
    end

    after { travel_back }

    it { is_expected.to eq [postlaunch] }
  end
end
