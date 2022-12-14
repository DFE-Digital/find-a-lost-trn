require "rails_helper"

RSpec.describe ScheduleZendeskTicketsForDeletionJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    context "when run in a production environment" do
      before do
        allow(HostingEnvironment).to receive(:production?).and_return(true)
      end

      it "fetches closed tickets" do
        expect(ZendeskService).to receive(
          :find_closed_tickets_from_6_months_ago,
        ).and_call_original
        perform
      end

      it "creates deleted ticket entries" do
        expect { perform }.to change { ZendeskDeleteRequest.count }.by 1
      end

      it "queues a background job to delete tickets" do
        perform
        expect(DeleteOldZendeskTicketsJob).to have_been_enqueued
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

      it "does not create deleted ticket entries" do
        expect { perform }.not_to change(ZendeskDeleteRequest, :count)
      end

      it "does not enqueue a background job to delete tickets" do
        perform
        expect(DeleteOldZendeskTicketsJob).not_to have_been_enqueued
      end
    end
  end
end
