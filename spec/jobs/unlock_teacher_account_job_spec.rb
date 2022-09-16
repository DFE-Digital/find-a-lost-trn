# frozen_string_literal: true
require "rails_helper"

RSpec.describe UnlockTeacherAccountJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(uid:, trn_request_id:) }
    let(:trn_request) do
      TrnRequest.create!(
        date_of_birth: "1990-01-01",
        email: "kevin@kevin.com",
        first_name: "kevin",
        ni_number: "1000000"
      )
    end
    let(:uid) { "f7891223-7661-e411-8047-005056822391" }
    let(:trn_request_id) { trn_request.id }

    before do
      FeatureFlag.activate(:unlock_teachers_self_service_portal_account)
      ActiveJob::Base.queue_adapter = :test
    end
    after do
      FeatureFlag.deactivate(:unlock_teachers_self_service_portal_account)
    end

    context "teacher account is locked in DQT", vcr: true do
      it "records that the unlock happened" do
        perform

        expect(trn_request.account_unlock_events.count).to eq(1)
      end
    end

    context "teacher account is already unlocked in DQT", vcr: true do
      it "does not record any unlocks" do
        perform

        expect(trn_request.account_unlock_events.empty?).to be_truthy
      end
    end

    context "retry unlock teacher account on client timeout", vcr: true do
      before do
        allow(DqtApi).to receive(:unlock_teacher!).and_raise(
          Faraday::TimeoutError
        )
      end

      it "runs the unlock teacher job asynchronously" do
        expect { DqtApi.find_trn!(trn_request) }.not_to raise_error
        expect(described_class).to have_been_enqueued.with(
          uid:,
          trn_request_id:
        )
      end
    end
  end
end
