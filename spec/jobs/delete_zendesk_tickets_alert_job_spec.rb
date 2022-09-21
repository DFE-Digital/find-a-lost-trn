# frozen_string_literal: true
require "rails_helper"

RSpec.describe DeleteZendeskTicketsAlertJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    before { allow(SlackClient).to receive(:create_message) }

    context "when the feature flag is active" do
      before { FeatureFlag.activate(:slack_alerts) }
      after { FeatureFlag.deactivate(:slack_alerts) }

      context "when there Zendesk tickets ready for deletion" do
        before do
          allow(ZendeskService).to receive(
            :find_closed_tickets_from_6_months_ago,
          ).and_return([1, 2])
        end

        it "sends the count as a Slack message" do
          perform
          expect(SlackClient).to have_received(:create_message).with(
            "There are 2 Zendesk tickets scheduled for deletion tomorrow. http://localhost:3000/support/zendesk",
          )
        end
      end

      context "when there are no Zendesk tickets for deletion" do
        before do
          allow(ZendeskService).to receive(
            :find_closed_tickets_from_6_months_ago,
          ).and_return([])
        end

        it "sends the latest count as a Slack message" do
          perform
          expect(SlackClient).to have_received(:create_message).with(
            "There are 0 Zendesk tickets scheduled for deletion tomorrow. http://localhost:3000/support/zendesk",
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
