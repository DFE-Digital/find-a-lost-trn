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

  describe "#custom_title" do
    it "Uses client_title if it is set" do
      session[:client_title] = "Custom Client Title"
      result = custom_title("Page Title")
      expect(result).to eq("Custom Client Title")
    end

    it "Defaults to page_title if client_title is not set" do
      result = custom_title("Page Title")
      expect(result).to eq(
        "Page Title - Find a lost teacher reference number (TRN)"
      )
    end

    it "escapes evil input" do
      session[:client_title] = '<script>alert("evil")</script>'
      result = custom_title("Page Title")
      expect(result).to eq("alert(\"evil\")")
    end
  end
end
