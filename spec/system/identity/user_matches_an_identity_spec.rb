# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Get an identity", type: :system do
  include SummaryListHelpers

  scenario "User matches an identity", vcr: { record: :once } do
    given_the_service_is_open
    given_i_am_authorized_as_a_support_user
    given_the_identity_endpoint_is_open

    when_i_simulate_an_identity_journey
    and_submit_my_official_name
    and_submit_my_preferred_name
    and_submit_my_dob
    and_submit_my_nino
    then_the_check_answers_page_contains_the_answers_i_submitted

    when_i_press_the_continue_button
    then_i_am_redirected_to_the_callback
  end

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_i_am_authorized_as_a_support_user
    page.driver.basic_authorize("test", "test")
  end

  def given_the_identity_endpoint_is_open
    FeatureFlag.activate(:identity_open)
  end

  def when_i_simulate_an_identity_journey
    visit support_interface_identity_simulate_path
    click_on "Continue"
    click_on "Submit"
  end

  def and_submit_my_official_name
    expect(page.current_path).to eq name_path

    fill_in "First name", with: "Steven"
    fill_in "Last name", with: "Toast"
    choose "No", visible: false
    click_on "Continue"
  end

  def and_submit_my_preferred_name
    expect(page.current_path).to eq preferred_name_path
    expect(page).to have_content "Is Steven Toast your preferred name?"

    click_on "Continue"
    expect(page).to have_content "Tell us if this is your preferred name"
    choose "No", visible: false
    click_on "Continue"
    expect(page).to have_content "Enter your preferred first name"
    expect(page).to have_content "Enter your preferred last name"

    choose "No", visible: false
    fill_in "Preferred first name", with: "Kevin"
    fill_in "Preferred last name", with: "E"
    click_on "Continue"
  end

  def and_submit_my_dob
    expect(page.current_path).to eq date_of_birth_path

    fill_in "Day", with: "01"
    fill_in "Month", with: "01"
    fill_in "Year", with: "1990"
    click_on "Continue"
  end

  def and_submit_my_nino
    expect(page.current_path).to eq have_ni_number_path

    choose "Yes", visible: false
    click_on "Continue"
    fill_in "What is your National Insurance number?", with: "AA123456A"
    click_on "Continue"
  end

  def then_the_check_answers_page_contains_the_answers_i_submitted
    expect(page.current_path).to eq check_answers_path

    within_summary_row("Name") { expect(page).to have_content "Steven Toast" }
    within_summary_row("Preferred name") do
      expect(page).to have_content "Kevin E"
    end
    within_summary_row("Date of birth") do
      expect(page).to have_content "1 January 1990"
    end
    within_summary_row("National Insurance number") do
      expect(page).to have_content "AA 12 34 56 A"
    end
  end

  def when_i_press_the_continue_button
    click_on "Continue"
  end

  def then_i_am_redirected_to_the_callback
    expect(page).to have_content(
      "You have completed a simulated Identity journey",
    )
  end
end
