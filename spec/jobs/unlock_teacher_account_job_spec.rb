# frozen_string_literal: true
require "rails_helper"

RSpec.describe UnlockTeacherAccountJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(uid:) }
    let(:trn_request) do
      TrnRequest.new(
        date_of_birth: "1990-01-01",
        email: "kevin@kevin.com",
        first_name: "kevin",
        ni_number: "1000000"
      )
    end
    let(:uid) { "f7891223-7661-e411-8047-005056822391" }

    before do
      FeatureFlag.activate(:unlock_teachers_self_service_portal_account)
      ActiveJob::Base.queue_adapter = :test
    end
    after do
      FeatureFlag.deactivate(:unlock_teachers_self_service_portal_account)
    end

    context "retry unlock teacher account on client timeout", vcr: true do
      before do
        allow(DqtApi).to receive(:unlock_teacher!).and_raise(
          Faraday::TimeoutError
        )
      end

      it "runs the unlock teacher job asynchronously" do
        expect { DqtApi.find_trn!(trn_request) }.not_to raise_error
        expect(described_class).to have_been_enqueued.with(uid:)
      end
    end
  end
end
