# frozen_string_literal: true
require "rails_helper"

RSpec.describe "TRN requests", type: :system do
  before do
    given_the_service_is_open
    given_the_zendesk_integration_feature_is_enabled
    given_the_use_dqt_api_feature_is_enabled
  end

  it "handles a TRN with active sanctions", vcr: true do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_confirm_i_have_a_trn_number
    when_i_press_continue
    when_i_fill_in_my_email_address
    and_i_press_continue
    when_i_fill_in_the_name_form
    when_i_complete_my_date_of_birth
    when_i_choose_yes
    when_i_press_continue
    when_i_fill_in_my_ni_number
    when_i_press_continue
    then_i_see_the_check_answers_page

    when_i_press_the_submit_button
    then_i_see_the_zendesk_confirmation_page
    and_i_receive_an_email_with_the_zendesk_ticket_number
  end

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_the_use_dqt_api_feature_is_enabled
    FeatureFlag.activate(:use_dqt_api)
  end

  def given_the_zendesk_integration_feature_is_enabled
    FeatureFlag.activate(:zendesk_integration)
  end

  def given_i_am_on_the_home_page
    visit root_path
  end

  def when_i_press_the_start_button
    click_on "Start now"
  end

  def when_i_confirm_i_have_a_trn_number
    choose "Yes", visible: false
    when_i_press_continue
  end

  def when_i_press_continue
    click_on "Continue"
  end
  alias_method :and_i_press_continue, :when_i_press_continue

  def when_i_fill_in_the_name_form
    fill_in "First name", with: "Audrey"
    fill_in "Last name", with: "Coady"
    when_i_press_continue
  end

  def when_i_complete_my_date_of_birth
    fill_in "Day", with: "05"
    fill_in "Month", with: "05"
    fill_in "Year", with: "1999"
    click_on "Continue"
  end

  def when_i_fill_in_my_ni_number
    fill_in "What is your National Insurance number?", with: "JN123456A"
  end
  alias_method :and_i_fill_in_my_ni_number, :when_i_fill_in_my_ni_number

  def when_i_fill_in_my_email_address
    fill_in "Your email address", with: "test@example.com"
  end
  alias_method :and_i_fill_in_my_email_address, :when_i_fill_in_my_email_address

  def when_i_choose_yes
    choose "Yes", visible: false
  end
  alias_method :and_i_choose_yes, :when_i_choose_yes

  def when_i_press_the_submit_button
    click_on "Submit"
  end
  alias_method :and_i_press_the_submit_button, :when_i_press_the_submit_button

  def then_i_see_the_zendesk_confirmation_page
    expect(page.driver.browser.current_title).to start_with(
      "We’ve received your request"
    )
    expect(page).to have_content("We’ve received your request")
    expect(page).to have_content("give the helpdesk your request number: 42")
  end

  def then_i_see_the_check_answers_page
    expect(page).to have_current_path("/check-answers")
    expect(page.driver.browser.current_title).to start_with(
      "Check your answers"
    )
    expect(page).to have_content("Check your answers")
    expect(page).to have_content("Audrey Coady")
    expect(page).to have_content("Date of birth")
    expect(page).to have_content("5 May 1999")
  end

  def and_i_receive_an_email_with_the_zendesk_ticket_number
    open_email("test@example.com")
    expect(current_email.subject).to eq(
      "We’ve received the information you submitted"
    )
    expect(current_email.body).to include(
      "give the helpdesk your ticket number: 42"
    )
  end
end
