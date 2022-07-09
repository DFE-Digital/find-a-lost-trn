# frozen_string_literal: true
require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#shy_email" do
    it "softly hyphenates an email" do
      result = shy_email("john.doe@digital.education.gov.uk")
      expect(result).to eq(
        "john&shy;.doe&shy;@digital&shy;.education&shy;.gov&shy;.uk"
      )
    end

    it "escapes evil input" do
      result = shy_email('<script>alert("evil")</script>')
      expect(result).to eq('alert&shy;"evil')
    end
  end

  describe "#number_with_delimiter" do
    it "adds commas to a number" do
      result = number_with_delimiter(1_234_567)
      expect(result).to eq("1,234,567")
    end
  end

  describe "#trn_request_count_percent" do
    it "returns 0% when the total is 0" do
      result =
        trn_request_count_percent(
          { total: 0, cnt_trn_found: 0 },
          :cnt_trn_found
        )
      expect(result).to be_empty
    end

    it "returns percentage using the passed attributes and keys" do
      result =
        trn_request_count_percent(
          { total: 50, cnt_trn_found: 25 },
          :cnt_trn_found
        )
      expect(result).to eq("(50%)")
    end
  end
end
