# frozen_string_literal: true
require "rails_helper"

RSpec.describe ZendeskHealthJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    before { allow(SlackClient).to receive(:create_message) }

    context "when the feature flag is active" do
      before { FeatureFlag.activate(:zendesk_health_check) }

      after { FeatureFlag.deactivate(:zendesk_health_check) }

      context "when there have been no TRN requests with a Zendesk ticket ID in the last 24 hours" do
        it "sends an alert about no Zendesk tickets as a Slack message" do
          perform
          expect(SlackClient).to have_received(:create_message).with(
            "No Zendesk tickets created in the last 24 hours on http://test/"
          )
        end
      end

      context "when there is a TRN request with a Zendesk ticket ID in the last 24 hours" do
        before do
          create(:trn_request, :has_zendesk_ticket, checked_at: Time.current)
        end

        it "no-ops" do
          perform
          expect(SlackClient).not_to have_received(:create_message)
        end
      end
    end

    context "when the feature flag is inactive" do
      before { FeatureFlag.deactivate(:zendesk_health_check) }

      it "no-ops" do
        perform
        expect(SlackClient).not_to have_received(:create_message)
      end
    end
  end
end
