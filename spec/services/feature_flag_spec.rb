# frozen_string_literal: true
require "rails_helper"

RSpec.describe FeatureFlag do
  describe ".activate" do
    it "activates a feature" do
      expect { described_class.activate("zendesk_integration") }.to(
        change { described_class.active?("zendesk_integration") }.from(
          false
        ).to(true)
      )
    end

    it "records the change in the database" do
      feature = Feature.create_or_find_by!(name: "zendesk_integration")
      feature.update!(active: false)
      expect { described_class.activate("zendesk_integration") }.to(
        change { feature.reload.active }.from(false).to(true)
      )
    end
  end

  describe ".deactivate" do
    it "deactivates a feature" do
      # To avoid flakey tests where activation/deactivation happens at the same time
      travel(5.minutes) do
        described_class.activate("zendesk_integration")
      end
      expect { described_class.deactivate("zendesk_integration") }.to(
        change { described_class.active?("zendesk_integration") }.from(true).to(
          false
        )
      )
    end

    it "records the change in the database" do
      feature = Feature.create_or_find_by!(name: "zendesk_integration")
      feature.update!(active: true)
      expect { described_class.deactivate("zendesk_integration") }.to(
        change { feature.reload.active }.from(true).to(false)
      )
    end
  end
end
