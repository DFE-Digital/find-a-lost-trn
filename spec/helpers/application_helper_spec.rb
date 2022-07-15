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
end
