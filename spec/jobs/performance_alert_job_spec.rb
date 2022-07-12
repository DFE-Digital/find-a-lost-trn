# frozen_string_literal: true
require "rails_helper"

RSpec.describe PerformanceAlertJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    before { allow(SlackClient).to receive(:create_message) }

    context "when the feature flag is active" do
      before { FeatureFlag.activate(:slack_alerts) }
      after { FeatureFlag.deactivate(:slack_alerts) }

      context "when there have been TRN requests in the last 7 days" do
        before { create(:trn_request) }

        it "sends the latest performance data as a Slack message" do
          perform
          expect(SlackClient).to have_received(:create_message).with(
            "There have been 1 TRN request started in the last 7 days on http://localhost:3000/performance"
          )
        end
      end

      context "when there have been no TRN requests in the last 7 days" do
        it "sends the latest performance data as a Slack message" do
          perform
          expect(SlackClient).to have_received(:create_message).with(
            "There have been 0 TRN requests started in the last 7 days on http://localhost:3000/performance"
          )
        end
      end

      context "when the feature flags is inactive" do
        before { FeatureFlag.deactivate(:slack_alerts) }

        it "no-ops" do
          perform
          expect(SlackClient).not_to have_received(:create_message)
        end
      end
    end
  end
end
