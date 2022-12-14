# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Identity", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_a_support_user
    given_the_identity_endpoint_is_open
  end

  after { deactivate_feature_flags }

  it "redirects to name page when parameters are verified correctly" do
    when_i_access_the_identity_endpoint
    then_i_see_the_name_page
  end

  it "does not verify with modified parameters" do
    given_the_service_is_open
    when_i_access_the_identity_endpoint_with_modified_parameters_it_raises_an_error
  end

  it "does not allow user to change their email" do
    when_i_access_the_identity_endpoint
    then_i_see_the_name_page

    when_i_try_to_go_to_the_email_page
    then_i_see_the_name_page
  end

  context "when sending the trn to the Identity API" do
    it "redirects back to Get An Identity", vcr: true do
      when_i_access_the_identity_endpoint
      and_i_complete_and_submit_the_name_form
      when_i_complete_and_submit_the_preferred_name_form
      and_i_complete_and_submit_my_date_of_birth
      then_i_see_the_check_answers_page

      when_i_press_the_continue_button
      then_i_am_redirected_to_the_callback
      and_the_title_of_the_service_is_find_a_lost_trn
    end

    context "after being redirected to the callback" do
      it "cannot go back to the check answers page", vcr: true do
        when_i_access_the_identity_endpoint
        and_i_complete_and_submit_the_name_form
        when_i_complete_and_submit_the_preferred_name_form
        and_i_complete_and_submit_my_date_of_birth
        then_i_see_the_check_answers_page

        when_i_press_the_continue_button
        then_i_am_redirected_to_the_callback

        when_i_try_to_go_to_the_check_answers_page
        then_i_am_redirected_to_the_callback
      end
    end

    context "when there is no trn match", vcr: true do
      before do
        allow(DqtApi).to receive(:find_trn!).and_raise(DqtApi::NoResults)
      end

      it "sends a blank trn to Get an Identity and redirects to the client callback URL" do
        when_i_access_the_identity_endpoint
        and_i_complete_and_submit_the_name_form
        when_i_complete_and_submit_the_preferred_name_form
        and_i_complete_and_submit_my_date_of_birth
        and_i_have_a_ni_number
        and_i_complete_and_submit_my_ni_number
        and_i_do_not_know_the_trn
        and_i_have_not_been_awarded_qts
        then_i_see_the_check_answers_page

        when_i_press_the_continue_button
        then_i_see_the_no_match_page
        and_i_see_the_correct_no_match_content

        when_i_submit_anyway
        then_i_am_redirected_to_the_callback

        when_i_try_to_go_to_the_check_answers_page
        then_i_am_redirected_to_the_callback
      end

      def and_an_identity_zendesk_ticket_is_raised
        trn_request = TrnRequest.last
        ticket_subject = GDS_ZENDESK_CLIENT.ticket.options.fetch(:subject)
        expect(
          ticket_subject,
        ).to eq "[Find a lost TRN - Identity auth] Support request from #{trn_request.name}"
      end
    end
  end

  context "ask for TRN page" do
    it "matches if they don't match on other criteria", vcr: true do
      when_i_access_the_identity_endpoint
      then_i_see_the_name_page

      when_i_complete_and_submit_the_name_form
      when_i_complete_and_submit_the_preferred_name_form
      then_i_see_the_date_of_birth_page

      when_i_complete_and_submit_my_wrong_date_of_birth
      then_i_see_the_have_ni_number_page

      when_i_dont_have_a_ni_number
      then_i_see_the_ask_trn_page

      when_i_submit_my_trn
      then_i_see_the_check_answers_page
    end

    it "does not ask if they match on other criteria", vcr: true do
      when_i_access_the_identity_endpoint
      then_i_see_the_name_page

      when_i_complete_and_submit_the_name_form
      when_i_complete_and_submit_the_preferred_name_form
      then_i_see_the_date_of_birth_page

      when_i_complete_and_submit_my_date_of_birth
      then_i_see_the_check_answers_page
    end

    it "asks for QTS if they do not match on any criteria", vcr: true do
      when_i_access_the_identity_endpoint
      then_i_see_the_name_page

      when_i_complete_and_submit_the_name_form
      when_i_complete_and_submit_the_preferred_name_form
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
      when_i_access_the_identity_endpoint
      then_i_see_the_name_page
      then_i_should_see_the_client_title_from_get_an_identity
    end
  end

  it "renders a link to the calling service" do
    when_i_access_the_identity_endpoint
    then_i_see_the_name_page

    when_i_click_on_the_header
    then_i_am_redirected_to_the_callback
    and_the_title_of_the_service_is_find_a_lost_trn
  end

  private

  def when_i_access_the_identity_endpoint
    visit support_interface_identity_simulate_path
    click_on "Continue"
    click_on "Submit"
  end

  def when_i_access_the_identity_endpoint_with_modified_parameters_it_raises_an_error
    params = {
      redirect_url: "https://authserveruri/",
      client_title: "New Title",
      email: "john.smith@example.com",
      journey_id: "9ddccb62-ec13-4ea7-a163-c058a19b8222",
      sig: "an invalid sig",
    }

    expect { post identity_path, params: }.to raise_error(
      IdentityController::IdentityDataError,
    )
  end

  def when_i_complete_and_submit_the_name_form
    fill_in "First name", with: "Kevin"
    fill_in "Last name", with: "E"
    choose "No", visible: false
    click_on "Continue"
  end
  alias_method :and_i_complete_and_submit_the_name_form,
               :when_i_complete_and_submit_the_name_form

  def when_i_complete_and_submit_the_preferred_name_form
    choose "Yes", visible: false
    click_on "Continue"
  end

  def when_i_complete_and_submit_my_date_of_birth
    fill_in "Day", with: "01"
    fill_in "Month", with: "01"
    fill_in "Year", with: "1990"
    click_on "Continue"
  end
  alias_method :and_i_complete_and_submit_my_date_of_birth,
               :when_i_complete_and_submit_my_date_of_birth

  def when_i_complete_and_submit_my_wrong_date_of_birth
    fill_in "Day", with: "01"
    fill_in "Month", with: "01"
    fill_in "Year", with: "1999"
    click_on "Continue"
  end

  def when_i_have_a_ni_number
    choose "Yes", visible: false
    click_on "Continue"
  end
  alias_method :and_i_have_a_ni_number, :when_i_have_a_ni_number

  def when_i_dont_have_a_ni_number
    choose "No", visible: false
    click_on "Continue"
  end

  def when_i_complete_and_submit_my_ni_number
    fill_in "What is your National Insurance number?", with: "AA123456A"
    click_on "Continue"
  end
  alias_method :and_i_complete_and_submit_my_ni_number,
               :when_i_complete_and_submit_my_ni_number

  def when_i_do_not_know_the_trn
    choose "No, I need to continue without my TRN", visible: false
    click_on "Continue"
  end
  alias_method :and_i_do_not_know_the_trn, :when_i_do_not_know_the_trn

  def when_i_submit_my_trn
    choose "Yes, I know my TRN", visible: false
    fill_in "What is your TRN?", with: "2921020"
    click_on "Continue"
  end

  def when_i_submit_my_wrong_trn
    choose "Yes, I know my TRN", visible: false
    fill_in "What is your TRN?", with: "1234567"
    click_on "Continue"
  end

  def when_i_have_not_been_awarded_qts
    choose "No", visible: false
    click_on "Continue"
  end
  alias_method :and_i_have_not_been_awarded_qts,
               :when_i_have_not_been_awarded_qts

  def when_i_click_on_the_header
    click_on "Register for a National Professional Qualification"
  end

  def then_i_see_the_check_answers_page
    expect(page).to have_content("Check your answers")
  end

  def then_i_see_the_name_page
    expect(page).to have_content("What’s your name?")
  end

  def then_i_see_the_date_of_birth_page
    expect(page).to have_content("Your date of birth")
  end

  def then_i_see_the_have_ni_number_page
    expect(page).to have_content("Do you have a National Insurance number")
  end

  def then_i_see_the_ni_number_page
    expect(response).to redirect_to("/ni-number")
  end

  def then_i_see_the_ask_trn_page
    expect(page).to have_content("Do you know your teacher reference number")
  end

  def then_i_see_the_have_awarded_qts_page
    expect(page).to have_content(
      "Have you been awarded qualified teacher status",
    )
  end

  def when_i_try_to_go_to_the_email_page
    visit email_path
  end

  def when_i_try_to_go_to_the_check_answers_page
    visit check_answers_path
  end

  def when_i_press_the_continue_button
    click_on "Continue"
  end

  def then_i_see_the_no_match_page
    expect(page).to have_content("We could not find you")
  end

  def then_i_am_redirected_to_the_callback
    expect(page).to have_content(
      "You have completed a simulated Identity journey",
    )
  end

  def then_i_should_see_the_client_title_from_get_an_identity
    expect(page).to have_content("")
  end

  def and_i_see_the_correct_no_match_content
    expect(page).to have_content("We could not find you")
    expect(page).to have_content("Check your answers")
    expect(page).not_to have_content("We could not find your TRN")
    expect(page).not_to have_content("Check your details")
  end

  def when_i_submit_anyway
    choose "No, submit these details, they are correct", visible: false
    click_on "Continue"
  end

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def deactivate_feature_flags
    FeatureFlag.deactivate(:identity_open)
  end

  def given_i_am_authorized_as_a_support_user
    page.driver.basic_authorize("test", "test")
  end

  def given_the_identity_endpoint_is_open
    FeatureFlag.activate(:identity_open)
  end

  def and_the_title_of_the_service_is_find_a_lost_trn
    expect(page).to have_content("Find a lost teacher reference number (TRN)")
  end
end
