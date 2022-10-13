# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Get an identity", type: :system do
  scenario "User matches an identity", vcr: { record: :all }, pending: true do
    given_the_service_is_open
    given_i_am_authorized_as_a_support_user
    given_the_identity_endpoint_is_open

    when_i_simulate_an_identity_journey
    and_submit_my_official_name
    and_submit_my_preferred_name
    and_submit_my_dob
    and_submit_my_nino
    and_submit_my_trn
    and_confirm_i_have_qts
    and_submit_where_i_received_qts
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
    expect(page).to have_content "What’s your name?"
    expect(page).to have_content "Use the name on your official documents"

    fill_in "First name", with: "Kevin"
    fill_in "Last name", with: "E"
    choose "No, I’ve not changed my name", visible: false
    click_on "Continue"
  end
end

