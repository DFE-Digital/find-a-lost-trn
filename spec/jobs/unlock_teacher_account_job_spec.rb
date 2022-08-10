# frozen_string_literal: true
require "rails_helper"

RSpec.describe UnlockTeacherAccountJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(teacher_account) }
    let(:trn_request) do
      TrnRequest.new(
        date_of_birth: "1990-01-01",
        email: "kevin@kevin.com",
        first_name: "kevin",
        ni_number: "1000000"
      )
    end
    let(:teacher_account) do
      {
        "trn" => "2921020",
        "emailAddresses" => ["anonymous@anonymousdomain.org.net.co.uk"],
        "firstName" => "Kevin",
        "lastName" => "Evans",
        "dateOfBirth" => "1990-01-01",
        "nationalInsuranceNumber" => "AA123456A",
        "uid" => "f7891223-7661-e411-8047-005056822391"
      }
    end

    before do
      FeatureFlag.activate(:unlock_teachers_self_service_portal_account)
      allow(DqtApi).to receive(:unlock_teacher!).and_raise(
        Faraday::TimeoutError
      )
      ActiveJob::Base.queue_adapter = :test
    end
    after do
      FeatureFlag.deactivate(:unlock_teachers_self_service_portal_account)
    end

    context "retry unlock teacher account on client timeout", vcr: true do
      it "runs the unlock teacher job asynchronously" do
        expect { DqtApi.find_trn!(trn_request) }.not_to raise_error
        expect(described_class).to have_been_enqueued.with(teacher_account)
      end
    end
  end
end
