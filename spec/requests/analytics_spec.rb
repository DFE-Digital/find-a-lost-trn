# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Analytics request events", type: :request do
  before { FeatureFlag.activate(:service_open) }
  after { FeatureFlag.deactivate(:service_open) }

  context "when send_analytics_events is active" do
    before { FeatureFlag.activate(:send_analytics_events) }
    after { FeatureFlag.deactivate(:send_analytics_events) }

    it "sends a web request event on the analytics queue" do
      get "/start"

      expect(DfE::Analytics::SendEvents).to have_been_enqueued
        .on_queue("analytics")
        .with([hash_including("event_type" => "web_request")])
    end

    it "filters sensitive query parameters before sending" do
      get "/start?reset_password_token=abc"

      filtered_query = [{ "key" => "reset_password_token", "value" => ["[FILTERED]"] }]
      expect(DfE::Analytics::SendEvents).to have_been_enqueued
        .with([hash_including("request_query" => filtered_query)])
    end

    it "still renders the page when the referer can't be parsed" do
      get "/start", headers: { "Referer" => "http://www.example.com/start?q=%" }

      aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(DfE::Analytics::SendEvents).to have_been_enqueued
          .with([hash_including("request_referer" => nil)])
      end
    end

    context "with a signed-in staff user" do
      include Devise::Test::IntegrationHelpers

      let(:staff) { create(:staff, confirmed_at: Time.zone.now) }

      before { sign_in staff }

      it "records which staff user made the request" do
        get "/support/features"

        expect(DfE::Analytics::SendEvents).to have_been_enqueued
          .with([hash_including("user_id" => staff.id)])
      end
    end

    context "with a support user signed in through HTTP basic auth" do
      let(:credentials) do
        ActionController::HttpAuthentication::Basic.encode_credentials(
          ENV.fetch("SUPPORT_USERNAME", "test"),
          ENV.fetch("SUPPORT_PASSWORD", "test"),
        )
      end

      it "sends the event without a user ID" do
        get "/support/features", headers: { "HTTP_AUTHORIZATION" => credentials }

        aggregate_failures do
          expect(response).to have_http_status(:ok)
          expect(DfE::Analytics::SendEvents).to have_been_enqueued
            .with([hash_including("user_id" => nil)])
        end
      end
    end

    it "records the session so a journey can be followed across requests" do
      get "/start"
      session_id = session.id.to_s

      expect(DfE::Analytics::SendEvents).to have_been_enqueued
        .with([hash_including("data" => [{ "key" => "session_id", "value" => [session_id] }])])
    end
  end

  it "sends nothing while send_analytics_events is inactive" do
    get "/start"

    expect(DfE::Analytics::SendEvents).not_to have_been_enqueued
  end
end
