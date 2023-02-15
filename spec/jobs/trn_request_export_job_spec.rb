require "rails_helper"

RSpec.describe TrnRequestExportJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    before do
      allow(TrnExportMailer).to receive(:monthly_report).and_return(
        double(deliver_later: true),
      )
    end

    context "when the feature flag is active" do
      before { FeatureFlag.activate(:automated_trn_exports) }
      after { FeatureFlag.deactivate(:automated_trn_exports) }

      context "when there have been TRN requests in the previous month" do
        before do
          travel_to 1.month.ago do
            create(:trn_request)
          end
        end

        it "sends the previous month's TRN requests as a CSV attached to a Slack message" do
          perform
          trn_request = TrnRequest.first
          trn_request_row = [
            trn_request.id,
            trn_request.trn,
            trn_request.email,
            trn_request.created_at,
            trn_request.updated_at,
          ].join(",")
          expect(TrnExportMailer).to have_received(:monthly_report).with(
            "Id,Trn,Email,Created At,Updated At\n#{trn_request_row}\n",
          )
        end
      end

      context "when the feature flags is inactive" do
        before { FeatureFlag.deactivate(:automated_trn_exports) }

        it "no-ops" do
          perform
          expect(TrnExportMailer).not_to have_received(:monthly_report)
        end
      end
    end
  end
end
