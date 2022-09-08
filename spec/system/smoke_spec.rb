# frozen_string_literal: true
require "spec_helper"
require "capybara/rspec"
require "capybara/cuprite"

Capybara.javascript_driver = :cuprite
Capybara.always_include_port = false

RSpec.describe "Smoke test", type: :system, js: true, smoke_test: true do
  it "works as expected" do
    when_i_am_authorized_as_a_support_user
    when_i_visit_the_start_page
    then_i_see_the_start_page

    when_i_press_the_start_button
    then_i_see_the_check_trn_page

    when_i_confirm_i_have_a_trn_number
    then_i_see_the_ask_questions_page

    when_i_press_continue
    then_i_see_the_email_page

    when_i_fill_in_my_email_address
    when_i_press_continue
    then_i_see_the_name_page

    when_i_fill_in_the_name_form
    then_i_see_the_date_of_birth_page

    when_i_complete_my_date_of_birth
    then_i_see_the_have_ni_page

    when_i_choose_no
    when_i_press_continue
    then_i_see_the_awarded_qts_page

    when_i_choose_yes
    when_i_press_continue
    then_i_see_the_itt_provider_page

    when_i_fill_in_my_itt_provider
    when_i_press_continue
    then_i_see_the_check_answers_page
  end

  it "/health/all returns 200" do
    page.visit("#{ENV["HOSTING_DOMAIN"]}/health/all")
    expect(page.status_code).to eq(200)
  end

  private

  def then_i_see_the_ask_questions_page
    expect(page).to have_content(
      "We’ll ask you some questions to help find your TRN"
    )
  end

  def then_i_see_the_awarded_qts_page
    expect(page).to have_content(
      "Have you been awarded qualified teacher status (QTS)?"
    )
  end

  def then_i_see_the_check_answers_page
    expect(page).to have_content("Check your answers")
    expect(page).to have_content("Kevin E")
    expect(page).to have_content("kevin­@kevin­.com") # NB: This is kevin&shy;@kevin&shy;.com
    expect(page).to have_content("Date of birth")
    expect(page).to have_content("1 January 1990")
  end

  def then_i_see_the_check_trn_page
    expect(page).to have_content("Check if you have a TRN")
  end

  def then_i_see_the_date_of_birth_page
    expect(page).to have_content("Your date of birth")
  end

  def then_i_see_the_email_page
    expect(page).to have_content("Your email address")
  end

  def then_i_see_the_have_ni_page
    expect(page).to have_content("Do you have a National Insurance number?")
  end

  def then_i_see_the_itt_provider_page
    expect(page).to have_content(
      "Did a university, SCITT or school award your QTS?"
    )
  end

  def then_i_see_the_name_page
    expect(page).to have_content("Your name")
  end

  def then_i_see_the_start_page
    expect(page).to have_content("Find a lost teacher reference number (TRN)")
  end

  def when_i_am_authorized_as_a_support_user
    page.driver.basic_authorize(
      ENV["SUPPORT_USERNAME"],
      ENV["SUPPORT_PASSWORD"]
    )
  end

  def when_i_choose_no
    choose "No", visible: false
  end

  def when_i_choose_yes
    choose "Yes", visible: false
  end

  def when_i_complete_my_date_of_birth
    fill_in "Day", with: "01"
    fill_in "Month", with: "01"
    fill_in "Year", with: "1990"
    when_i_press_continue
  end

  def when_i_confirm_i_have_a_trn_number
    choose "Yes", visible: false
    when_i_press_continue
  end

  def when_i_fill_in_my_email_address
    fill_in "Your email address", with: "kevin@kevin.com"
  end

  def when_i_fill_in_my_itt_provider
    choose "Yes", visible: false
    fill_in "Where did you get your QTS?",
            with: "Test ITT Provider",
            visible: false
  end

  def when_i_fill_in_the_name_form
    fill_in "First name", with: "Kevin"
    fill_in "Last name", with: "E"
    choose "No, I’ve not changed my name", visible: false
    when_i_press_continue
  end

  def when_i_press_continue
    click_on "Continue"
  end

  def when_i_press_the_start_button
    click_on "Start now"
  end

  def when_i_visit_the_start_page
    page.visit("#{ENV["HOSTING_DOMAIN"]}/start")
  end
end
