# frozen_string_literal: true
require "rails_helper"

# Guards against the request-replay issue flagged by the ITHC: a replayed (or
# double-submitted) `PUT /trn-request` must not repeat any side effect — emails,
# Zendesk tickets or Identity API submissions. The guard is persisted on the
# record (`submitted_at`) rather than the session, because the cookie-based
# session means a replayed request carries the original cookie and would not see
# a session flag set by the first request.
RSpec.describe "TrnRequests replay protection", type: :request do
  before { FeatureFlag.activate(:service_open) }
  after { FeatureFlag.deactivate(:service_open) }

  let(:params) { { trn_request: { answers_checked: true } } }

  def stub_current_trn_request(trn_request)
    allow_any_instance_of(TrnRequestsController).to receive(
      :trn_request,
    ).and_return(trn_request)
  end

  context "when a successful TRN match is replayed" do
    let(:trn_request) { create(:trn_request, :has_trn) }

    before { stub_current_trn_request(trn_request) }

    it "emails the found TRN only once" do
      expect {
        put trn_request_path, params: params
        put trn_request_path, params: params
      }.to have_enqueued_mail(TeacherMailer, :found_trn).once
    end

    it "redirects the replay to the TRN found page without reprocessing" do
      put trn_request_path, params: params
      put trn_request_path, params: params

      expect(response).to redirect_to(trn_found_path)
    end
  end

  context "when a request that raises a support ticket is replayed" do
    let(:trn_request) do
      create(:trn_request, awarded_qts: false, trn: nil)
    end

    before do
      stub_current_trn_request(trn_request)
      allow(DqtApi).to receive(:find_trn!).and_raise(DqtApi::TooManyResults)
      allow(ZendeskService).to receive(:create_ticket!)
    end

    it "creates a single Zendesk ticket" do
      put trn_request_path, params: params
      put trn_request_path, params: params

      expect(ZendeskService).to have_received(:create_ticket!).once
    end

    it "sends the information received email only once" do
      expect {
        put trn_request_path, params: params
        put trn_request_path, params: params
      }.to have_enqueued_mail(TeacherMailer, :information_received).once
    end
  end

  context "when no TRN is found" do
    let(:trn_request) do
      create(:trn_request, awarded_qts: false, trn: nil)
    end

    before { stub_current_trn_request(trn_request) }

    it "releases the claim so the user can correct and resubmit" do
      allow(DqtApi).to receive(:find_trn!).and_raise(DqtApi::NoResults)
      put trn_request_path, params: params

      expect(response).to redirect_to(no_match_path)
      expect(trn_request.reload.submitted_at).to be_nil
    end

    it "processes a corrected resubmission after a no match" do
      allow(DqtApi).to receive(:find_trn!).and_raise(DqtApi::NoResults)
      put trn_request_path, params: params

      allow(DqtApi).to receive(:find_trn!).and_return(
        "trn" => "1234567", "hasActiveSanctions" => false,
      )
      expect { put trn_request_path, params: params }.to have_enqueued_mail(
        TeacherMailer,
        :found_trn,
      ).once
    end
  end

  context "when an identity submission is replayed" do
    let(:trn_request) do
      create(
        :trn_request,
        :has_trn,
        :from_get_an_identity,
        official_name_preferred: true,
        submitted_at: Time.current,
      )
    end

    before do
      stub_current_trn_request(trn_request)
      allow(IdentityApi).to receive(:submit_trn!)
    end

    it "does not resubmit the TRN to Get An Identity" do
      put trn_request_path, params: params

      expect(IdentityApi).not_to have_received(:submit_trn!)
    end
  end
end
