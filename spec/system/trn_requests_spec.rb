# frozen_string_literal: true
require "rails_helper"

RSpec.describe "TRN requests", type: :system do
  before { given_the_service_is_open }

  after { deactivate_feature_flags }

  it "completing a request", vcr: true do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    then_i_see_the_check_trn_page

    when_i_confirm_i_have_a_trn_number
    then_i_see_the_ask_questions_page

    when_i_press_continue
    then_i_see_the_email_page

    when_i_fill_in_my_email_address
    and_i_press_continue
    then_i_see_the_name_page

    when_i_fill_in_the_name_form
    then_i_see_the_date_of_birth_page

    when_i_complete_my_date_of_birth
    then_i_see_the_have_ni_page

    when_i_choose_no
    and_i_press_continue
    then_i_see_the_awarded_qts_page

    when_i_choose_yes
    and_i_press_continue
    then_i_see_the_itt_provider_page

    when_i_fill_in_my_itt_provider
    and_i_press_continue
    then_i_see_the_check_answers_page

    when_i_press_the_submit_button
    then_i_see_the_zendesk_confirmation_page
    and_i_receive_an_email_with_the_zendesk_ticket_number

    when_i_navigate_to_the_email_page
    then_i_see_the_email_page
    and_my_email_is_not_filled_in
  end

  it "trying to skip steps", vcr: true do
    given_i_am_on_the_home_page
    when_i_try_to_go_straight_to_the_confirmation_page
    then_i_see_the_home_page

    when_i_try_to_go_to_the_check_answers_page
    then_i_see_the_email_page

    when_i_try_to_go_to_the_name_page
    then_i_see_the_email_page

    when_i_fill_in_my_email_address
    and_i_press_continue
    then_i_see_the_name_page

    when_i_try_to_go_to_the_date_of_birth_page
    then_i_see_the_name_page

    when_i_fill_in_the_name_form
    then_i_see_the_date_of_birth_page

    when_i_try_to_go_to_the_ni_number_page
    then_i_see_the_date_of_birth_page

    when_i_complete_my_date_of_birth
    then_i_see_the_have_ni_page

    when_i_try_to_go_to_the_ni_number_page
    then_i_see_the_have_ni_page
    when_i_try_to_go_to_the_itt_provider_page
    then_i_see_the_have_ni_page

    when_i_choose_no
    and_i_press_continue
    then_i_see_the_awarded_qts_page

    when_i_choose_no
    and_i_press_continue
    then_i_see_the_check_answers_page
  end

  it "entering the NI number", vcr: true do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_confirm_i_have_a_trn_number
    when_i_press_continue
    then_i_see_the_email_page

    when_i_fill_in_my_email_address
    and_i_press_continue
    then_i_see_the_name_page

    when_i_fill_in_the_name_form
    then_i_see_the_date_of_birth_page

    when_i_complete_my_date_of_birth
    then_i_see_the_have_ni_page

    when_i_press_continue
    then_i_see_the_ni_missing_error

    when_i_choose_yes_to_ni_number
    then_i_see_the_ni_number_page

    when_i_press_continue
    then_i_see_the_ni_number_missing_error

    when_i_enter_a_valid_ni_number
    then_i_see_the_check_answers_page
  end

  it "when the user has a NI number but says they do not remember it",
     vcr: true do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_confirm_i_have_a_trn_number
    when_i_press_continue
    when_i_fill_in_the_email_form
    when_i_fill_in_the_name_form
    when_i_complete_my_date_of_birth
    when_i_choose_yes_to_ni_number
    then_i_see_the_ni_number_page

    when_i_click_on_the_forgotten_ni_number_link
    and_i_press_continue_without_it
    then_i_see_the_awarded_qts_page
  end

  it "changing my name", vcr: true do
    given_i_have_completed_a_trn_request
    when_i_press_change_name
    then_i_see_the_existing_name

    when_i_enter_a_new_name
    then_i_see_the_updated_name
  end

  it "changing my previous name", vcr: true do
    given_i_have_completed_a_trn_request
    when_i_press_change_name
    then_i_see_the_existing_name

    when_i_enter_a_previous_name
    then_i_see_the_updated_previous_name
  end

  it "changed my previous name but prefer not to specify", vcr: true do
    given_i_have_completed_a_trn_request
    when_i_press_change_name
    then_i_see_the_existing_name

    when_i_prefer_not_to_specify_a_previous_name
    then_i_do_not_see_a_previous_name
  end

  it "when I do not specify if my name has changed" do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    then_i_see_the_check_trn_page

    when_i_confirm_i_have_a_trn_number
    then_i_see_the_ask_questions_page

    when_i_press_continue
    then_i_see_the_email_page

    when_i_fill_in_my_email_address
    and_i_press_continue
    then_i_see_the_name_page

    when_i_fill_in_the_name_form_without_specifying_if_my_name_has_changed
    then_i_see_a_validation_error
  end

  it "changing my NI number", vcr: true do
    given_i_have_completed_a_trn_request
    when_i_press_change_ni_number
    then_no_should_be_checked

    when_i_choose_yes
    and_i_press_continue
    and_i_fill_in_my_ni_number
    and_i_press_continue
    then_i_see_the_updated_ni_number
  end

  it "changing my email address", vcr: true do
    given_i_have_completed_a_trn_request
    when_i_press_change_email
    and_i_fill_in_my_new_email_address
    and_i_press_continue
    then_i_see_the_updated_email_address
  end

  it "changing my ITT provider", vcr: true do
    given_i_have_completed_a_trn_request
    when_i_press_change_awarded_qts
    then_no_should_be_checked

    when_i_choose_yes
    and_i_press_continue
    when_i_choose_yes
    and_i_fill_in_my_itt_provider
    and_i_press_continue
    then_i_see_the_updated_itt_provider

    when_i_press_change_awarded_qts
    then_yes_should_be_checked
    when_i_choose_no
    and_i_press_continue
    then_i_see_no_qts_awarded
  end

  it "changing my date of birth", vcr: true do
    given_i_have_completed_a_trn_request
    when_i_press_change_date_of_birth
    then_i_see_the_date_of_birth_page
    and_the_date_of_birth_is_prepopulated
  end

  it "pressing back" do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_press_back
    then_i_see_the_home_page
  end

  context "when the user has reached the name question" do
    it "pressing back" do
      given_i_am_on_the_home_page
      when_i_press_the_start_button
      when_i_confirm_i_have_a_trn_number
      when_i_press_continue
      when_i_fill_in_the_email_form
      then_i_see_the_name_page

      when_i_press_back
      then_i_see_the_email_page
    end
  end

  context "when the user has reached the have NI question" do
    it "pressing back", vcr: true do
      given_i_am_on_the_home_page
      when_i_press_the_start_button
      when_i_confirm_i_have_a_trn_number
      when_i_press_continue
      when_i_fill_in_the_email_form
      when_i_fill_in_the_name_form
      when_i_complete_my_date_of_birth
      then_i_see_the_have_ni_page

      when_i_press_back
      then_i_see_the_date_of_birth_page
    end
  end

  context "when the user has reached the ITT provider question" do
    it "pressing back", vcr: true do
      given_i_am_on_the_home_page
      when_i_press_the_start_button
      when_i_confirm_i_have_a_trn_number
      when_i_press_continue
      when_i_fill_in_the_email_form
      when_i_fill_in_the_name_form
      when_i_complete_my_date_of_birth
      and_i_choose_no
      and_i_press_continue
      then_i_see_the_awarded_qts_page

      when_i_press_back
      then_i_see_the_have_ni_page
    end
  end

  context "when the user has reached the check answers page" do
    it "pressing back", vcr: true do
      given_i_have_completed_a_trn_request
      when_i_press_change_email
      and_i_press_back
      then_i_see_the_check_answers_page
      when_i_press_change_awarded_qts
      then_i_see_the_awarded_qts_page
      when_i_press_back
      then_i_see_the_check_answers_page
      when_i_press_change_ni_number
      then_i_see_the_have_ni_page
      when_i_press_back
      then_i_see_the_check_answers_page
    end
  end

  it "refreshing the page and pressing back", vcr: true do
    given_i_have_completed_a_trn_request
    when_i_press_change_email
    then_i_see_the_email_page

    when_i_refresh_the_page
    and_i_press_back
    then_i_see_the_check_answers_page
  end

  it "ITT provider validations", vcr: true do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_confirm_i_have_a_trn_number
    when_i_press_continue
    when_i_fill_in_the_email_form
    when_i_fill_in_the_name_form
    when_i_complete_my_date_of_birth
    then_i_see_the_have_ni_page

    when_i_choose_no
    and_i_press_continue
    then_i_see_the_awarded_qts_page

    when_i_press_continue
    then_i_see_a_validation_error

    when_i_choose_yes
    and_i_press_continue
    then_i_see_the_itt_provider_page

    when_i_choose_yes
    and_i_press_continue
    then_i_see_a_validation_error
  end

  it "no TRN" do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_choose_no_trn
    then_i_see_the_no_trn_page
  end

  it "taking longer than usual" do
    given_it_is_taking_longer_than_usual
    when_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_confirm_i_have_a_trn_number
    when_i_press_continue
    then_i_see_the_taking_longer_page
    when_i_press_continue
    then_i_see_the_email_page
  end

  it "service is closed" do
    given_the_service_is_closed
    and_i_visit_the_home_page
    then_i_should_not_see_the_home_page

    when_i_am_authorized_as_a_support_user
    and_i_visit_the_home_page
    then_i_should_see_the_home_page

    given_the_service_is_open
    and_i_visit_the_home_page
    then_i_should_see_the_home_page
  end

  it "displays the TRN returned by the DQT API", vcr: true do
    when_i_have_completed_a_trn_request
    and_i_press_the_submit_button

    then_i_see_a_message_to_check_my_email
    and_i_receive_an_email_with_the_trn_number
  end

  it "shows the no match page and opens a Zendesk ticket when there is no match",
     vcr: true do
    when_i_have_completed_a_trn_request_that_wont_match
    and_i_press_the_submit_button
    then_i_see_the_no_match_page
    and_i_see_my_not_matching_details

    when_i_press_continue
    then_i_see_the_no_match_validation_error

    when_i_choose_yes_i_have_different_details
    and_i_press_continue
    then_i_see_the_check_answers_page_with_not_matching_details

    when_i_press_the_submit_button
    then_i_see_the_no_match_page

    when_i_choose_no_my_details_are_correct
    and_i_press_continue
    then_i_see_the_zendesk_confirmation_page
    and_i_receive_an_email_with_the_zendesk_ticket_number
    and_a_job_to_check_zendesk_is_queued
  end

  it "matches eagerly", vcr: true do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_confirm_i_have_a_trn_number
    when_i_press_continue
    when_i_fill_in_the_email_form
    when_i_fill_in_the_name_form
    when_i_complete_my_date_of_birth
    when_i_choose_yes
    when_i_press_continue
    when_i_fill_in_my_ni_number
    when_i_press_continue
    then_i_see_the_check_answers_page

    when_i_press_back
    then_i_see_the_ni_number_page

    when_i_press_continue
    then_i_see_the_check_answers_page

    when_i_press_the_submit_button
    then_i_see_a_message_to_check_my_email
    and_i_receive_an_email_with_the_trn_number
  end

  it "matches on the date of birth step", vcr: true do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_confirm_i_have_a_trn_number
    when_i_press_continue
    when_i_fill_in_the_email_form
    when_i_fill_in_the_name_form
    when_i_complete_my_date_of_birth
    then_i_see_the_check_answers_page

    when_i_press_the_submit_button
    then_i_see_a_message_to_check_my_email
    and_i_receive_an_email_with_the_trn_number
  end

  context "when the use_dqt_api_itt_providers feature is enabled" do
    it "allows users to pick from a list of ITT providers", vcr: true do
      given_the_use_dqt_api_itt_providers_feature_is_enabled
      given_i_have_completed_a_trn_request
      when_i_press_change_awarded_qts
      then_no_should_be_checked

      when_i_choose_yes
      and_i_press_continue
      when_i_choose_yes
      and_i_type_in_scitt
      then_i_see_provider_suggestions

      when_i_choose_a_suggested_provider
      and_i_press_continue
      then_i_see_the_updated_suggested_provider

      # Test if caching is working; shouldn't update the vcr tapes
      when_i_press_change_itt_provider
      then_i_see_the_itt_provider_page
    end
  end

  context "when the Zendesk API is unavailable" do
    before { allow(Sentry).to receive(:capture_exception) }

    it "handles the failure gracefully", vcr: true do
      given_the_zendesk_connection_is_unavailable
      when_i_have_completed_a_trn_request_that_has_multiple_matches
      when_i_press_the_submit_button
      then_i_see_the_delayed_information_page
      and_a_job_gets_queued_to_retry_the_zendesk_ticket_creation
      and_i_receive_an_email_about_the_delay
      and_sentry_receives_a_warning_about_the_failure
    end
  end

  private

  def and_a_job_gets_queued_to_retry_the_zendesk_ticket_creation
    expect(CreateZendeskTicketJob).to have_been_enqueued.with(
      TrnRequest.last.id
    )
  end

  def and_a_job_to_check_zendesk_is_queued
    expect(CheckZendeskTicketForTrnJob).to have_been_enqueued.with(
      TrnRequest.last.id
    )
  end

  def and_i_receive_an_email_about_the_delay
    perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob)
    open_email("kevin@kevin.com")
    expect(current_email.subject).to eq(
      "We’ve received the information you submitted"
    )
    expect(current_email.body).to include(
      "We’ve received the information you submitted, and you’ll get an email with your TRN if we find a match."
    )
  end

  def and_i_receive_an_email_with_the_trn_number
    perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob)
    open_email("kevin@kevin.com")
    expect(current_email.subject).to eq("Your TRN is 2921020")
  end

  def and_i_receive_an_email_with_the_zendesk_ticket_number
    perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob)
    open_email("kevin@kevin.com")
    expect(current_email.subject).to eq(
      "We’ve received the information you submitted"
    )
    expect(current_email.body).to include(
      "give the helpdesk your ticket number: 42"
    )
  end

  def and_sentry_receives_a_warning_about_the_failure
    expect(Sentry).to have_received(:capture_exception)
  end

  def and_the_date_of_birth_is_prepopulated
    expect(page).to have_field("Day", with: "1")
    expect(page).to have_field("Month", with: "1")
    expect(page).to have_field("Year", with: "1990")
  end

  def and_my_name_is_not_filled_in
    expect(page).not_to have_field("First name", with: "Kevin")
  end

  def and_my_email_is_not_filled_in
    expect(page).not_to have_field("Email", with: "kevin@kevin.com")
  end

  def deactivate_feature_flags
    FeatureFlag.deactivate(:processing_delays)
    FeatureFlag.deactivate(:service_open)
    FeatureFlag.deactivate(:use_dqt_api_itt_providers)
  end

  def given_i_am_on_the_home_page
    visit root_path
  end
  alias_method :when_i_am_on_the_home_page, :given_i_am_on_the_home_page
  alias_method :and_i_visit_the_home_page, :given_i_am_on_the_home_page

  def given_i_have_completed_a_trn_request
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_confirm_i_have_a_trn_number
    when_i_press_continue
    then_i_see_the_email_page

    when_i_fill_in_my_email_address
    and_i_press_continue
    when_i_fill_in_the_name_form
    when_i_complete_my_date_of_birth
    when_i_choose_no
    and_i_press_continue
    then_i_see_the_awarded_qts_page

    when_i_choose_no
    and_i_press_continue
  end
  alias_method :when_i_have_completed_a_trn_request,
               :given_i_have_completed_a_trn_request

  def when_i_have_completed_a_trn_request_that_wont_match
    given_i_have_completed_a_trn_request
    when_i_press_change_name
    when_i_fill_in_the_name_form_with_data_that_will_not_match
  end

  def when_i_have_completed_a_trn_request_that_has_multiple_matches
    given_i_have_completed_a_trn_request
    when_i_press_change_name
    when_i_fill_in_the_name_form_with_data_that_will_match_multiple_times
  end

  def given_it_is_taking_longer_than_usual
    FeatureFlag.activate(:processing_delays)
  end

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_the_service_is_closed
    FeatureFlag.deactivate(:service_open)
  end

  def given_the_use_dqt_api_itt_providers_feature_is_enabled
    FeatureFlag.activate(:use_dqt_api_itt_providers)
  end

  def given_the_zendesk_connection_is_unavailable
    allow(ZendeskService).to receive(:create_ticket!).and_raise(
      ZendeskService::ConnectionError
    )
  end

  def then_i_see_the_updated_suggested_provider
    expect(page).to have_content("Astra SCITT")
  end

  def then_i_see_provider_suggestions
    expect(page).to have_content("Astra SCITT")
  end

  def then_i_see_a_message_to_check_my_email
    expect(page).to have_content("We’ve sent it to")
  end

  def then_i_see_the_ask_questions_page
    expect(page).to have_current_path("/ask-questions")
    expect(page.driver.browser.current_title).to start_with(
      "We’ll ask you some questions to help find your TRN"
    )
    expect(page).to have_content(
      "We’ll ask you some questions to help find your TRN"
    )
  end

  def then_i_see_the_awarded_qts_page
    expect(page).to have_current_path("/awarded-qts")
    expect(page.driver.browser.current_title).to start_with(
      "Have you been awarded qualified teacher status (QTS)?"
    )
    expect(page).to have_content(
      "Have you been awarded qualified teacher status (QTS)?"
    )
  end

  def then_i_see_the_check_answers_page
    expect(page).to have_current_path("/check-answers")
    expect(page.driver.browser.current_title).to start_with(
      "Check your answers"
    )
    expect(page).to have_content("Check your answers")
    expect(page).to have_content("Kevin E")
    expect(page).to have_content("kevin­@kevin­.com") # NB: This is kevin&shy;@kevin&shy;.com
    expect(page).to have_content("Date of birth")
    expect(page).to have_content("1 January 1990")
  end

  def then_i_see_the_check_answers_page_with_not_matching_details
    expect(page).to have_current_path("/check-answers")
    expect(page.driver.browser.current_title).to start_with(
      "Check your answers"
    )
    expect(page).to have_content("Check your answers")
    and_i_see_my_not_matching_details
  end

  def then_i_see_my_not_matching_details
    expect(page).to have_content("Do not Match me")
    expect(page).to have_content("kevin­@kevin­.com") # NB: This is kevin&shy;@kevin&shy;.com
    expect(page).to have_content("Date of birth")
    expect(page).to have_content("1 January 1990")
  end
  alias_method :and_i_see_my_not_matching_details,
               :then_i_see_my_not_matching_details

  def then_i_see_the_ni_missing_error
    expect(page).to have_content(
      "Tell us if you have a National Insurance number"
    )
  end

  def then_i_see_the_updated_itt_provider
    expect(page).to have_current_path("/check-answers")
    expect(page).to have_content("Where did you get your QTS?")
    expect(page).to have_content("Test ITT Provider")
  end

  def then_i_see_the_check_trn_page
    expect(page).to have_current_path("/check-trn")
    expect(page.driver.browser.current_title).to start_with(
      "Check if you have a TRN"
    )
    expect(page).to have_content("Check if you have a TRN")
  end

  def then_i_see_the_delayed_information_page
    expect(page.driver.browser.current_title).to start_with(
      "We’ve received your request"
    )
    expect(page).to have_content("We’ve received your request")
    expect(page).to have_content(
      "We have not confirmed this by email yet because of a technical problem. We'll try again later."
    )
  end

  def then_i_see_the_zendesk_confirmation_page
    expect(page.driver.browser.current_title).to start_with(
      "We’ve received your request"
    )
    expect(page).to have_content("We’ve received your request")
    expect(page).to have_content("give the helpdesk your request number: 42")
  end

  def then_i_see_the_date_of_birth_page
    expect(page).to have_current_path("/date-of-birth")
    expect(page.driver.browser.current_title).to start_with(
      "Your date of birth"
    )
    expect(page).to have_content("Your date of birth")
  end
  alias_method :then_i_am_redirected_to_the_date_of_birth_page,
               :then_i_see_the_date_of_birth_page

  def then_i_see_the_email_page
    expect(page).to have_current_path("/email")
    expect(page.driver.browser.current_title).to start_with(
      "Your email address"
    )
    expect(page).to have_content("Your email address")
  end

  def then_i_see_the_existing_name
    expect(page).to have_field("First name", with: "Kevin")
    expect(page).to have_field("Last name", with: "E")
  end

  def then_i_see_the_home_page
    expect(page).to have_current_path(start_path)
    expect(page).to have_content(I18n.t("service.name"))
  end

  def then_i_see_the_itt_provider_page
    expect(page).to have_current_path("/itt-provider")
    expect(page.driver.browser.current_title).to start_with(
      "Did a university, SCITT or school award your QTS?"
    )
    expect(page).to have_content(
      "Did a university, SCITT or school award your QTS?"
    )
  end

  def then_i_see_the_have_ni_page
    expect(page).to have_current_path("/have-ni-number")
    expect(page.driver.browser.current_title).to start_with(
      "Do you have a National Insurance number?"
    )
    expect(page).to have_content("Do you have a National Insurance number?")
  end

  def then_i_see_the_name_page
    expect(page).to have_current_path("/name")
    expect(page.driver.browser.current_title).to start_with("Your name")
    expect(page).to have_content("Your name")
  end
  alias_method :then_i_am_redirected_to_the_name_page, :then_i_see_the_name_page

  def then_i_see_the_email_page
    expect(page).to have_current_path("/email")
  end

  def then_i_see_the_ni_number_page
    expect(page).to have_current_path("/ni-number")
    expect(page.driver.browser.current_title).to start_with(
      "What is your National Insurance number?"
    )
    expect(page).to have_content("What is your National Insurance number?")
  end

  def then_i_see_the_ni_number_missing_error
    expect(page).to have_content("Enter a National Insurance number")
  end

  def then_i_see_the_no_trn_page
    expect(page).to have_current_path("/you-dont-have-a-trn")
    expect(page.driver.browser.current_title).to start_with(
      "If you do not have a TRN"
    )
    expect(page).to have_content("If you do not have a TRN")
  end

  def then_i_see_the_taking_longer_page
    expect(page).to have_current_path("/longer-than-normal")
  end

  def then_i_see_the_updated_email_address
    expect(page).to have_content("new@example.com")
  end

  def then_i_see_the_updated_name
    expect(page).to have_content("Kevin Smith")
  end

  def then_i_see_the_updated_previous_name
    expect(page).to have_content("Previous name")
    expect(page).to have_content("Kev Jones")
  end

  def then_i_do_not_see_a_previous_name
    expect(page).to_not have_content("Previous name")
  end

  def then_i_see_the_updated_ni_number
    expect(page).to have_content("AA 12 34 56 A")
  end

  def then_i_see_a_validation_error
    expect(page).to have_content("There is a problem")
  end

  def then_i_see_the_no_match_validation_error
    expect(page).to have_content("There is a problem")
    expect(page).to have_content(
      "Choose if you want to try different details, or keep the current ones"
    )
  end

  def then_i_see_the_no_match_page
    expect(page).to have_content("We could not find your TRN")
  end

  def then_i_see_no_qts_awarded
    expect(page).to have_current_path("/check-answers")
    expect(page).to have_content("Have you been awarded QTS?")
    expect(page).to have_content("No")
    expect(page).not_to have_content("Where did you get your QTS?")
  end

  def then_i_should_see_the_home_page
    expect(page).to have_content("Find a lost teacher reference number")
  end

  def then_i_should_not_see_the_home_page
    expect(page).not_to have_content("Find a lost teacher reference number")
  end

  def then_no_should_be_checked
    expect(find_field("No", checked: true, visible: false)).to be_truthy
  end

  def then_yes_should_be_checked
    expect(find_field("Yes", checked: true, visible: false)).to be_truthy
  end

  def when_i_am_on_the_check_answers_page
    given_i_have_completed_a_trn_request
  end

  def when_i_am_on_the_email_page
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_complete_my_date_of_birth
    when_i_choose_no_ni_number
    when_i_choose_no_itt_provider
  end

  def when_i_am_on_the_name_page
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    then_i_see_the_check_trn_page

    when_i_confirm_i_have_a_trn_number
    then_i_see_the_ask_questions_page

    when_i_press_continue
    then_i_see_the_name_page
  end

  def when_i_choose_no_itt_provider
    choose "No, I was awarded QTS another way", visible: false
    when_i_press_continue
  end

  def when_i_choose_no_trn
    choose "No", visible: false
    when_i_press_continue
  end

  def when_i_confirm_i_have_a_trn_number
    choose "Yes", visible: false
    when_i_press_continue
  end

  def when_i_enter_a_new_name
    fill_in "First name", with: "Kevin"
    fill_in "Last name", with: "Smith"
    choose "No, I’ve not changed my name", visible: false
    when_i_press_continue
  end

  def when_i_enter_a_previous_name
    choose "Yes, I’ve changed my name", visible: false
    fill_in "Previous first name (optional)", with: "Kev"
    fill_in "Previous last name (optional)", with: "Jones"
    when_i_press_continue
  end

  def when_i_prefer_not_to_specify_a_previous_name
    choose "Prefer not to say", visible: false
    when_i_press_continue
  end

  def when_i_fill_in_the_name_form
    fill_in "First name", with: "Kevin"
    fill_in "Last name", with: "E"
    choose "No, I’ve not changed my name", visible: false
    when_i_press_continue
  end

  def when_i_fill_in_the_name_form_without_specifying_if_my_name_has_changed
    fill_in "First name", with: "Kevin"
    fill_in "Last name", with: "E"
    when_i_press_continue
  end

  def when_i_fill_in_the_email_form
    when_i_fill_in_my_email_address
    when_i_press_continue
  end

  def when_i_fill_in_the_name_form_with_data_that_will_not_match
    fill_in "First name", with: "Do not"
    fill_in "Last name", with: "Match me"
    when_i_press_continue
  end

  def when_i_fill_in_the_name_form_with_data_that_will_match_multiple_times
    fill_in "First name", with: "John"
    fill_in "Last name", with: "Smith"
    when_i_press_continue
  end

  def when_i_fill_in_my_itt_provider
    choose "Yes", visible: false
    fill_in "Where did you get your QTS?",
            with: "Test ITT Provider",
            visible: false
  end
  alias_method :and_i_fill_in_my_itt_provider, :when_i_fill_in_my_itt_provider

  def when_i_fill_in_my_ni_number
    fill_in "What is your National Insurance number?", with: "AA123456A"
  end
  alias_method :and_i_fill_in_my_ni_number, :when_i_fill_in_my_ni_number

  def when_i_choose_a_suggested_provider
    find("#itt-provider-form-itt-provider-name-field").native.send_keys(:down)
    find("body").native.send_key(:tab)
  end

  def when_i_choose_no
    choose "No", visible: false
  end
  alias_method :and_i_choose_no, :when_i_choose_no

  def when_i_choose_yes
    choose "Yes", visible: false
  end
  alias_method :and_i_choose_yes, :when_i_choose_yes

  def when_i_press_continue
    click_on "Continue"
  end
  alias_method :and_i_press_continue, :when_i_press_continue

  def when_i_choose_yes_to_ni_number
    choose "Yes", visible: false
    click_on "Continue"
  end

  def when_i_choose_yes_i_have_different_details
    choose "Yes, I have different details I can try", visible: false
  end

  def when_i_choose_no_my_details_are_correct
    choose "No, submit these details, they are correct", visible: false
  end

  def when_i_enter_a_valid_ni_number
    fill_in "What is your National Insurance number?", with: "AA123456A"
    click_on "Continue"
  end

  def when_i_complete_my_date_of_birth
    fill_in "Day", with: "01"
    fill_in "Month", with: "01"
    fill_in "Year", with: "1990"
    click_on "Continue"
  end

  def when_i_press_back
    click_on "Back"
  end
  alias_method :and_i_press_back, :when_i_press_back

  def when_i_fill_in_my_email_address
    fill_in "Your email address", with: "kevin@kevin.com"
  end
  alias_method :and_i_fill_in_my_email_address, :when_i_fill_in_my_email_address

  def when_i_fill_in_my_new_email_address
    fill_in "Your email address", with: "new@example.com"
  end
  alias_method :and_i_fill_in_my_new_email_address,
               :when_i_fill_in_my_new_email_address

  def when_i_press_change_date_of_birth
    click_on "Change date of birth"
  end

  def when_i_press_change_email
    click_on "Change email address"
  end

  def when_i_press_change_awarded_qts
    click_on "Change awarded QTS"
  end

  def when_i_press_change_itt_provider
    click_on "Change teacher training provider"
  end

  def when_i_press_change_name
    click_on "Change name"
  end

  def when_i_press_change_ni_number
    click_on "Change national insurance number"
  end

  def when_i_press_continue
    click_on "Continue"
  end

  def when_i_press_the_start_button
    click_on "Start now"
  end

  def when_i_press_the_submit_button
    click_on "Submit"
  end
  alias_method :and_i_press_the_submit_button, :when_i_press_the_submit_button

  def when_i_refresh_the_page
    page.driver.browser.refresh
  end

  def when_i_try_to_go_straight_to_the_confirmation_page
    visit helpdesk_request_submitted_path
  end

  def when_i_try_to_go_to_the_check_answers_page
    visit trn_request_path
  end

  def when_i_try_to_go_to_the_date_of_birth_page
    visit date_of_birth_path
  end

  def when_i_try_to_go_to_the_email_page
    visit email_path
  end

  def when_i_try_to_go_to_the_itt_provider_page
    visit itt_provider_path
  end

  def when_i_try_to_go_to_the_ni_number_page
    visit ni_number_path
  end

  def when_i_am_authorized_as_a_support_user
    page.driver.basic_authorize("test", "test")
  end

  def when_i_click_on_the_forgotten_ni_number_link
    find(
      ".govuk-details__summary-text",
      text: "I don’t know my National Insurance number"
    ).click
  end

  def and_i_press_continue_without_it
    click_on "Continue without it"
  end

  def and_i_type_in_scitt
    find("#itt-provider-form-itt-provider-name-field").native.send_keys "astra"
  end

  def when_i_navigate_to_the_name_page
    visit name_path
  end
  alias_method :when_i_try_to_go_to_the_name_page,
               :when_i_navigate_to_the_name_page

  def when_i_navigate_to_the_email_page
    visit email_path
  end
end
