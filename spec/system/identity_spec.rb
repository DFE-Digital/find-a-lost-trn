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
    then_i_see_the_name_page
  end

  it "does not verify with modified parameters" do
    when_i_access_the_identity_endpoint_with_modified_parameters_it_raises_an_error
  end

  it "does not allow user to change their email" do
    when_i_access_the_identity_endpoint_with_parameters
    then_i_see_the_name_page
    when_i_try_to_go_to_the_email_page
    then_i_see_the_name_page
  end

  it "does not ask for an email address", vcr: true do
    when_i_access_the_identity_endpoint_with_parameters
    then_i_see_the_name_page
    when_i_complete_and_submit_the_name_form
    then_i_see_the_date_of_birth_page
    when_i_complete_and_submit_my_date_of_birth
    then_i_see_the_check_answers_page
  end

  context "when sending the trn to the Identity API" do
    it "redirects back to Get An Identity", vcr: true do
      when_i_access_the_identity_endpoint_with_parameters
      and_i_complete_and_submit_the_name_form
      and_i_complete_and_submit_my_date_of_birth
      then_i_see_the_check_answers_page
      when_i_press_the_submit_button
      then_i_am_redirected_back_to_get_an_identity
    end

    context "when there is no trn match", vcr: true do
      before do
        allow(DqtApi).to receive(:find_trn!).and_raise(DqtApi::NoResults)
      end

      it "does not ask for an email address" do
        when_i_access_the_identity_endpoint_with_parameters
        then_i_see_the_name_page
        when_i_complete_and_submit_the_name_form
        then_i_see_the_date_of_birth_page
        when_i_complete_and_submit_my_date_of_birth
        then_i_see_the_have_ni_number_page
        when_i_have_a_ni_number
        then_i_see_the_ni_number_page
        when_i_complete_and_submit_my_ni_number
        then_i_see_the_ask_trn_page
        when_i_do_not_know_the_trn
        then_i_see_the_have_awarded_qts_page
        when_i_have_not_been_awarded_qts
        then_i_see_the_check_answers_page
      end

      it "sends a blank trn to Get an Identity and redirects back Get An Identity" do
        when_i_access_the_identity_endpoint_with_parameters
        and_i_complete_and_submit_the_name_form
        and_i_complete_and_submit_my_date_of_birth
        and_i_have_a_ni_number
        and_i_complete_and_submit_my_ni_number
        and_i_do_not_know_the_trn
        and_i_have_not_been_awarded_qts
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
        and_i_complete_and_submit_the_name_form
        and_i_complete_and_submit_my_date_of_birth
        and_i_have_a_ni_number
        and_i_complete_and_submit_my_ni_number
        and_i_have_not_been_awarded_qts
        then_i_see_the_check_answers_page
        when_i_press_the_submit_button
        then_sentry_receives_a_warning_about_the_failure
        and_i_am_redirected_to_the_error_page
      end
    end
  end

  context "ask for TRN page" do
    it "matches if they don't match on other criteria", vcr: true do
      when_i_access_the_identity_endpoint_with_parameters
      then_i_see_the_name_page

      when_i_complete_and_submit_the_name_form
      then_i_see_the_date_of_birth_page

      when_i_complete_and_submit_my_wrong_date_of_birth
      then_i_see_the_have_ni_number_page

      when_i_dont_have_a_ni_number
      then_i_see_the_ask_trn_page

      when_i_submit_my_trn
      then_i_see_the_check_answers_page
    end

    it "does not ask if they match on other criteria", vcr: true do
      when_i_access_the_identity_endpoint_with_parameters
      then_i_see_the_name_page

      when_i_complete_and_submit_the_name_form
      then_i_see_the_date_of_birth_page

      when_i_complete_and_submit_my_date_of_birth
      then_i_see_the_check_answers_page
    end

    it "asks for QTS if they do not match on any criteria", vcr: true do
      when_i_access_the_identity_endpoint_with_parameters
      then_i_see_the_name_page

      when_i_complete_and_submit_the_name_form
      then_i_see_the_date_of_birth_page

      when_i_complete_and_submit_my_wrong_date_of_birth
      then_i_see_the_have_ni_number_page

      when_i_dont_have_a_ni_number
      then_i_see_the_ask_trn_page

      when_i_submit_my_wrong_trn
      then_i_see_the_have_awarded_qts_page
    end
  end

  context "custom client_title from get an identity" do
    it "displays the client_title from get an identity journey" do
      when_i_access_the_identity_endpoint_with_parameters
      then_i_see_the_name_page
      then_i_should_see_the_client_title_from_get_an_identity
    end
  end

  private

  def when_i_access_the_identity_endpoint_with_parameters
    params = {
      redirect_uri: "https://authserveruri/",
      client_title: "The Client Title",
      email: "kevin.e@example.com",
      journey_id: "9ddccb62-ec13-4ea7-a163-c058a19b8222",
      sig: "2940250690ABB0055E0EF197E7C296BF5FF62587ECD7B39A2F88D08F3AC8A30E"
    }

    post identity_path, params:
  end

  def when_i_access_the_identity_endpoint_with_modified_parameters_it_raises_an_error
    params = {
      redirect_uri: "https://authserveruri/",
      client_title: "New Title",
      email: "john.smith@example.com",
      journey_id: "9ddccb62-ec13-4ea7-a163-c058a19b8222",
      sig: "2940250690ABB0055E0EF197E7C296BF5FF62587ECD7B39A2F88D08F3AC8A30E"
    }

    expect { post identity_path, params: }.to raise_error(
      IdentityController::IdentityDataError
    )
  end

  def when_i_complete_and_submit_the_name_form
    post "/name",
         params: {
           name_form: {
             first_name: "Kevin",
             last_name: "E",
             name_changed: false
           }
         }
  end
  alias_method :and_i_complete_and_submit_the_name_form,
               :when_i_complete_and_submit_the_name_form

  def when_i_complete_and_submit_my_date_of_birth
    post "/date-of-birth",
         params: {
           date_of_birth_form: {
             "date_of_birth(3i)" => "1",
             "date_of_birth(2i)" => "1",
             "date_of_birth(1i)" => "1990"
           }
         }
  end
  alias_method :and_i_complete_and_submit_my_date_of_birth,
               :when_i_complete_and_submit_my_date_of_birth

  def when_i_complete_and_submit_my_wrong_date_of_birth
    post "/date-of-birth",
         params: {
           date_of_birth_form: {
             "date_of_birth(3i)" => "1",
             "date_of_birth(2i)" => "1",
             "date_of_birth(1i)" => "1999"
           }
         }
  end

  def when_i_have_a_ni_number
    post "/have-ni-number",
         params: {
           has_ni_number_form: {
             has_ni_number: true
           }
         }
  end
  alias_method :and_i_have_a_ni_number, :when_i_have_a_ni_number

  def when_i_dont_have_a_ni_number
    post "/have-ni-number",
         params: {
           has_ni_number_form: {
             has_ni_number: false
           }
         }
  end

  def when_i_complete_and_submit_my_ni_number
    post "/ni-number",
         params: {
           ni_number_form: {
             ni_number: "AA123456A"
           },
           submit: "submit"
         }
  end
  alias_method :and_i_complete_and_submit_my_ni_number,
               :when_i_complete_and_submit_my_ni_number

  def when_i_do_not_know_the_trn
    post "/ask-trn", params: { ask_trn_form: { do_you_know_your_trn: false } }
  end
  alias_method :and_i_do_not_know_the_trn, :when_i_do_not_know_the_trn

  def when_i_submit_my_trn
    post "/ask-trn",
         params: {
           ask_trn_form: {
             do_you_know_your_trn: true,
             trn_from_user: "2921020"
           }
         }
  end

  def when_i_submit_my_wrong_trn
    post "/ask-trn",
         params: {
           ask_trn_form: {
             do_you_know_your_trn: true,
             trn_from_user: "1234567"
           }
         }
  end

  def when_i_have_not_been_awarded_qts
    post "/awarded-qts", params: { awarded_qts_form: { awarded_qts: false } }
  end
  alias_method :and_i_have_not_been_awarded_qts,
               :when_i_have_not_been_awarded_qts

  def then_i_see_the_check_answers_page
    expect(response).to redirect_to("/check-answers")
  end

  def then_i_see_the_ask_for_trn_page
    expect(response).to redirect_to("/ask-trn")
  end

  def then_i_see_the_name_page
    expect(response).to redirect_to("/name")
  end

  def then_i_see_the_date_of_birth_page
    expect(response).to redirect_to("/date-of-birth")
  end

  def then_i_see_the_have_ni_number_page
    expect(response).to redirect_to("/have-ni-number")
  end

  def then_i_see_the_ni_number_page
    expect(response).to redirect_to("/ni-number")
  end

  def then_i_see_the_ask_trn_page
    expect(response).to redirect_to("/ask-trn")
  end

  def then_i_see_the_have_awarded_qts_page
    expect(response).to redirect_to("/awarded-qts")
  end

  def then_i_see_the_have_itt_provider_page
    expect(response).to redirect_to("/itt-provider")
  end

  def when_i_try_to_go_to_the_email_page
    get email_path
  end

  def when_i_press_the_submit_button
    put "/trn-request", params: { trn_request: { answers_checked: true } }
  end
  alias_method :when_i_submit_anyway, :when_i_press_the_submit_button

  def then_i_see_the_no_match_page
    expect(response).to redirect_to("/no-match")
  end

  def then_i_am_redirected_back_to_get_an_identity
    expect(response).to redirect_to("https://authserveruri/")
  end

  def then_sentry_receives_a_warning_about_the_failure
    expect(Sentry).to have_received(:capture_exception)
  end

  def then_i_should_see_the_client_title_from_get_an_identity
    follow_redirect!
    page = response.parsed_body
    expect(page).to have_content("The Client Title")
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
