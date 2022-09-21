# frozen_string_literal: true
require "rails_helper"

RSpec.describe FeatureFlag do
  describe ".activate" do
    it "activates a feature" do
      expect { described_class.activate("slack_alerts") }.to(
        change { described_class.active?("slack_alerts") }.from(false).to(true),
      )
    end

    it "records the change in the database" do
      feature = Feature.create_or_find_by!(name: "slack_alerts")
      feature.update!(active: false)
      expect { described_class.activate("slack_alerts") }.to(
        change { feature.reload.active }.from(false).to(true),
      )
    end
  end

  describe ".deactivate" do
    it "deactivates a feature" do
      # To avoid flakey tests where activation/deactivation happens at the same time
      travel(5.minutes) { described_class.activate("slack_alerts") }
      expect { described_class.deactivate("slack_alerts") }.to(
        change { described_class.active?("slack_alerts") }.from(true).to(false),
      )
    end

    it "records the change in the database" do
      feature = Feature.create_or_find_by!(name: "slack_alerts")
      feature.update!(active: true)
      expect { described_class.deactivate("slack_alerts") }.to(
        change { feature.reload.active }.from(true).to(false),
      )
    end
  end
end
