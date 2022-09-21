require "rails_helper"

RSpec.describe CreateZendeskTicketJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(trn_request_id) }
    let(:trn_request) { create(:trn_request) }
    let(:trn_request_id) { trn_request.id }

    before do
      allow(ZendeskService).to receive(:create_ticket!)
      allow(TeacherMailer).to receive(:information_received).and_return(
        double(deliver_later: true),
      )
    end

    it "creates a Zendesk ticket" do
      expect(ZendeskService).to receive(:create_ticket!).with(trn_request)
      perform
    end

    it "sends an email to the teacher" do
      expect(TeacherMailer).to receive(:information_received).with(
        trn_request,
      ).and_return(double(deliver_later: true))
      perform
    end

    it "enqueues a job to check the Zendesk ticket for a TRN" do
      freeze_time do
        perform
        expect(CheckZendeskTicketForTrnJob).to have_been_enqueued.at(
          2.days.from_now,
        ).with(trn_request_id)
      end
    end

    context "when the Zendesk ticket is already created" do
      let(:trn_request) { create(:trn_request, :has_zendesk_ticket) }

      it "does not create another Zendesk ticket" do
        expect(ZendeskService).not_to receive(:create_ticket!)
        perform
      end
    end
  end
end
