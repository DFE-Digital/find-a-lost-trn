# frozen_string_literal: true
require "rails_helper"

RSpec.describe UnlockTeacherAccountJob, type: :job do
  describe "#perform_later" do
    subject(:perform) { described_class.new.perform(teacher_account) }
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

    context "retry unlock teacher account on client timeout" do
      it do
        expect { DqtApi.unlock_teacher!(teacher_account) }.to raise_error(
          Faraday::TimeoutError
        )
      end
      it do
        expect {
          described_class.perform_later(teacher_account)
        }.to have_enqueued_job.with(teacher_account).at(:no_wait)
      end
    end
  end
end
