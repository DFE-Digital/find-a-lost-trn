# frozen_string_literal: true
require "rails_helper"

RSpec.describe DfE::Analytics::FilteredRequestEvent do
  describe "#with_request_details" do
    let(:referer) { "http://example.com/staff/password/edit?reset_password_token=abc&page=1" }
    let(:rack_request) do
      instance_double(ActionDispatch::Request,
                      uuid: "123",
                      user_agent: "foo",
                      method: "GET",
                      original_fullpath: "/bar?page=2&reset_password_token=abc",
                      query_string: "page=2&reset_password_token=abc",
                      referer:,
                      remote_ip: "1.3.22.21",
                      headers: {})
    end
    let(:event) { described_class.new.with_request_details(rack_request).as_json }

    it "records the path the user requested, without its query string" do
      expect(event["request_path"]).to eq("/bar")
    end

    it "filters the request query with Rails' parameter filters" do
      expect(event["request_query"]).to eq(
        [
          { "key" => "page", "value" => ["2"] },
          { "key" => "reset_password_token", "value" => ["[FILTERED]"] },
        ],
      )
    end

    it "filters the referer's query with Rails' parameter filters" do
      expect(event["request_referer"]).to eq(
        "http://example.com/staff/password/edit?reset_password_token=%5BFILTERED%5D&page=1",
      )
    end

    context "with a referer that isn't a valid URI" do
      let(:referer) { "http://exa mple.com/?reset_password_token=abc" }

      it "leaves the referer out" do
        expect(event["request_referer"]).to be_nil
      end
    end

    context "with a referer whose query has invalid %-encoding" do
      let(:referer) { "http://example.com/start?q=%" }

      it "leaves the referer out" do
        expect(event["request_referer"]).to be_nil
      end
    end

    context "without a referer" do
      let(:referer) { nil }

      it "leaves the referer out" do
        expect(event["request_referer"]).to be_nil
      end
    end
  end
end
