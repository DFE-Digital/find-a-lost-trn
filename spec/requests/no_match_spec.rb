# frozen_string_literal: true
require "rails_helper"

# NoMatchController#create shares the same replayable side effects as
# TrnRequestsController#update (Zendesk ticket + email, or an Identity API
# submission). A replayed POST /no-match must not repeat them. See
# EnforceQuestionOrder#claim_submission! for the persisted, cookie-independent
# guard.
RSpec.describe "NoMatch replay protection", type: :request do
  before { FeatureFlag.activate(:service_open) }
  after { FeatureFlag.deactivate(:service_open) }

  let(:params) { { no_match_form: { try_again: "false" } } }

  def stub_current_trn_request(trn_request)
    allow_any_instance_of(NoMatchController).to receive(
      :trn_request,
    ).and_return(trn_request)
  end

  context "when submitting the details is replayed" do
    let(:trn_request) { create(:trn_request, awarded_qts: false, trn: nil) }

    before do
      stub_current_trn_request(trn_request)
      allow(ZendeskService).to receive(:create_ticket!)
    end

    it "creates a single Zendesk ticket" do
      post no_match_path, params: params
      post no_match_path, params: params

      expect(ZendeskService).to have_received(:create_ticket!).once
    end

    it "sends the information received email only once" do
      expect {
        post no_match_path, params: params
        post no_match_path, params: params
      }.to have_enqueued_mail(TeacherMailer, :information_received).once
    end
  end

  context "when an identity submission is replayed" do
    let(:trn_request) do
      create(
        :trn_request,
        :from_get_an_identity,
        official_name_preferred: true,
        awarded_qts: false,
        trn_from_user: "1234567",
        submitted_at: Time.current,
      )
    end

    before do
      stub_current_trn_request(trn_request)
      allow(IdentityApi).to receive(:submit_trn!)
    end

    it "does not resubmit the TRN to Get An Identity" do
      post no_match_path, params: params

      expect(IdentityApi).not_to have_received(:submit_trn!)
    end
  end
end
