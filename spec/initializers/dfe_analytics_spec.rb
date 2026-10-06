# frozen_string_literal: true
require "rails_helper"

RSpec.describe "DfE Analytics configuration" do
  # Terraform sets BIGQUERY_HIDDEN_POLICY_TAG. Before v1.16.1 the gem never
  # turned it into the :hidden policy tag, so PII columns went untagged
  it "uses BIGQUERY_HIDDEN_POLICY_TAG as the hidden policy tag" do
    tag = "projects/example/locations/europe-west2/taxonomies/1/policyTags/2"
    config = DfE::Analytics::Config.params

    begin
      ENV["BIGQUERY_HIDDEN_POLICY_TAG"] = tag
      DfE::Analytics::Config.configure(config)
    ensure
      ENV.delete("BIGQUERY_HIDDEN_POLICY_TAG")
    end

    expect(config.bigquery_policy_tags).to eq(hidden: tag)
  end
end
