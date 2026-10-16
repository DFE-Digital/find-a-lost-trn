# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Analytics field lists" do
  # A hidden field that isn't synced means the PII list has drifted from the
  # allowlist, so a column we meant to hide may be missing from BigQuery
  it "only hides fields that are synced" do
    unsynced = DfE::Analytics::Fields.diff_between(DfE::Analytics.hidden_pii,
                                                   DfE::Analytics.allowlist)

    expect(unsynced).to be_empty
  end
end
