# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Identity", type: :system do
  before do
    given_the_service_is_open
    given_the_identity_endpoint_is_open
  end

  after { deactivate_feature_flags }

  it "verifies the parameters" do
    when_i_access_the_identity_endpoint_with_parameters
    then_i_see_the_check_answers_page
  end

  it "does not verify with modified parameters" do
    when_i_access_the_identity_endpoint_with_modified_parameters_it_raises_an_error
  end

  it "does not allow user to change their email" do
    when_i_access_the_identity_endpoint_with_parameters
    then_i_see_the_check_answers_page
    when_i_try_to_go_to_the_email_page
    then_i_see_the_check_answers_page
  end

  context "when sending the trn to the Identity API" do
    it "redirects back to Get An Identity", vcr: true do
      when_i_access_the_identity_endpoint_with_parameters
      then_i_see_the_check_answers_page
      when_i_press_the_submit_button
      then_i_am_redirected_back_to_get_an_identity
    end

    context "when there is no trn match", vcr: true do
      before do
        allow(DqtApi).to receive(:find_trn!).and_raise(DqtApi::NoResults)
      end

      it "sends a blank trn to Get an Identity and redirects back Get An Identity" do
        when_i_access_the_identity_endpoint_with_parameters
        then_i_see_the_check_answers_page
        when_i_press_the_submit_button
        then_i_see_the_no_match_page
        when_i_submit_anyway
        then_i_am_redirected_back_to_get_an_identity
      end
    end

    context "when there is an Identity API error" do
      before do
        allow(Sentry).to receive(:capture_exception)
        FeatureFlag.activate(:identity_api_always_timeout)
      end

      after { FeatureFlag.deactivate(:identity_api_always_timeout) }

      it "redirects to the error page", vcr: true do
        when_i_access_the_identity_endpoint_with_parameters
        then_i_see_the_check_answers_page
        when_i_press_the_submit_button
        then_sentry_receives_a_warning_about_the_failure
        and_i_am_redirected_to_the_error_page
      end
    end
  end

  context "ask user for their TRN if they know it" do
    let(:trn_params) do
      {
        awarded_qts: false,
        first_name: "Kevin",
        email: "kevin.e@example.com",
        from_get_an_identity: true,
        itt_provider_enrolled: false,
        last_name: "E",
        ni_number: "AA123456A",
        has_ni_number: true,
        date_of_birth: Date.parse("1990-01-01")
      }
    end

    before do
      trn_request = TrnRequest.create!(trn_params)
      allow(TrnRequest).to receive(:create!).and_return(trn_request)
    end

    it "when user has not answered this question" do
      when_i_access_the_identity_endpoint_with_parameters
      then_i_see_the_ask_for_trn_page
    end

    context "when user has indicated they know their TRN" do
      let(:trn_params) do
        {
          awarded_qts: false,
          first_name: "Kevin",
          email: "kevin.e@example.com",
          from_get_an_identity: true,
          itt_provider_enrolled: false,
          last_name: "E",
          ni_number: "AA123456A",
          trn_from_user: "1234567",
          has_ni_number: true,
          date_of_birth: Date.parse("1990-01-01")
        }
      end
      it "skip asking the user for their TRN" do
        when_i_access_the_identity_endpoint_with_parameters
        then_i_see_the_check_answers_page
        then_i_see_the_trn_details_in_the_check_answers_summary("1234567")
      end
    end

    context "when user wants to continue without their TRN" do
      let(:trn_params) do
        {
          awarded_qts: false,
          first_name: "Kevin",
          email: "kevin.e@example.com",
          from_get_an_identity: true,
          itt_provider_enrolled: false,
          last_name: "E",
          ni_number: "AA123456A",
          trn_from_user: "",
          has_ni_number: true,
          date_of_birth: Date.parse("1990-01-01")
        }
      end
      it "skip asking the user for their TRN" do
        when_i_access_the_identity_endpoint_with_parameters
        then_i_see_the_check_answers_page
        then_i_see_the_trn_details_in_the_check_answers_summary(
          "I don’t know my TRN"
        )
      end
    end
  end

  private

  def when_i_access_the_identity_endpoint_with_parameters
    params = {
      redirect_uri: "https://authserveruri/",
      client_title: "The Client Title",
      email: "joe.bloggs@example.com",
      journey_id: "9ddccb62-ec13-4ea7-a163-c058a19b8222",
      sig: "E03C7295CF8B3C444C21D8D88B04D4B377615B68A92C83B3321A3F71CF8E4A6D"
    }

    post identity_path, params:
  end

  def when_i_access_the_identity_endpoint_with_modified_parameters_it_raises_an_error
    params = {
      redirect_uri: "https://authserveruri/",
      client_title: "New Title",
      email: "john.smith@example.com",
      journey_id: "9ddccb62-ec13-4ea7-a163-c058a19b8222",
      sig: "E03C7295CF8B3C444C21D8D88B04D4B377615B68A92C83B3321A3F71CF8E4A6D"
    }

    expect { post identity_path, params: }.to raise_error(
      IdentityController::IdentityDataError
    )
  end

  def then_i_see_the_check_answers_page
    expect(response).to redirect_to("/check-answers")
  end

  def then_i_see_the_ask_for_trn_page
    expect(response).to redirect_to("/ask-trn")
  end

  def when_i_try_to_go_to_the_email_page
    get email_path
  end

  def when_i_press_the_submit_button
    put "/trn-request", params: { trn_request: { answers_checked: true } }
  end

  def then_i_see_the_no_match_page
    expect(response).to redirect_to("/no-match")
  end

  def then_i_am_redirected_back_to_get_an_identity
    expect(response).to redirect_to("https://authserveruri/")
  end

  def then_sentry_receives_a_warning_about_the_failure
    expect(Sentry).to have_received(:capture_exception)
  end

  def then_i_see_the_trn_details_in_the_check_answers_summary(value)
    follow_redirect!
    page = response.parsed_body
    expect(page).to have_content("Teacher reference number (TRN)")
    expect(page).to have_content(value)
  end

  def and_i_am_redirected_to_the_error_page
    expect(response.status).to be(500)
  end

  def when_i_submit_anyway
    post "/no-match", params: { no_match_form: { try_again: false } }
  end

  def deactivate_feature_flags
    FeatureFlag.deactivate(:service_open)
    FeatureFlag.deactivate(:identity_open)
  end

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_the_identity_endpoint_is_open
    FeatureFlag.activate(:identity_open)
  end
end
