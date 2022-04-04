# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'TRN requests', type: :system do
  before { given_the_service_is_open }

  it 'completing a request' do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    then_i_see_the_check_trn_page

    when_i_confirm_i_have_a_trn_number
    then_i_see_the_ask_questions_page

    when_i_press_continue
    then_i_see_the_name_page

    when_i_fill_in_the_name_form
    then_i_see_the_date_of_birth_page

    when_i_complete_my_date_of_birth
    then_i_see_the_have_ni_page

    when_i_choose_no
    then_i_see_the_ni_page

    when_i_choose_no
    and_i_press_continue
    then_i_see_the_itt_provider_page

    when_i_choose_no
    and_i_press_continue
    then_i_see_the_email_page

    when_i_fill_in_my_email_address
    and_i_press_continue
    then_i_see_the_check_answers_page

    when_i_press_the_submit_button
    then_i_see_the_confirmation_page
  end

  it 'trying to skip steps' do
    given_i_am_on_the_home_page
    when_i_try_to_go_straight_to_the_confirmation_page
    then_i_see_the_home_page

    when_i_try_to_go_to_the_check_answers_page
    then_i_see_the_home_page

    when_i_am_on_the_name_page
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
    then_i_see_the_itt_provider_page

    when_i_try_to_go_to_the_email_page
    then_i_see_the_itt_provider_page

    when_i_choose_no
    and_i_press_continue
    then_i_see_the_email_page

    when_i_try_to_go_to_the_check_answers_page
    then_i_see_the_email_page
  end

  it 'entering the NI number' do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_confirm_i_have_a_trn_number
    when_i_press_continue
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
    then_i_see_the_itt_provider_page
  end

  it 'changing my name' do
    given_i_have_completed_a_trn_request
    when_i_press_change_name
    then_i_see_the_existing_name

    when_i_enter_a_new_name
    then_i_see_the_updated_name
  end

  it 'changing my NI number' do
    given_i_have_completed_a_trn_request
    when_i_press_change_ni_number
    then_no_should_be_checked

    when_i_choose_yes
    and_i_press_continue
    and_i_fill_in_my_ni_number
    and_i_press_continue
    then_i_see_the_updated_ni_number
  end

  it 'changing my email address' do
    given_i_have_completed_a_trn_request
    when_i_press_change_email
    and_i_fill_in_my_new_email_address
    and_i_press_continue
    then_i_see_the_updated_email_address
  end

  it 'changing my ITT provider' do
    given_i_have_completed_a_trn_request
    when_i_press_change_itt_provider
    then_no_should_be_checked

    when_i_choose_yes
    and_i_fill_in_my_itt_provider
    and_i_press_continue
    then_i_see_the_updated_itt_provider
  end

  it 'changing my date of birth' do
    given_i_have_completed_a_trn_request
    when_i_press_change_date_of_birth
    then_i_see_the_date_of_birth_page
    and_the_date_of_birth_is_prepopulated
  end

  it 'pressing back' do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_press_back
    then_i_see_the_home_page
  end

  context 'when the user has reached the date of birth question' do
    it 'pressing back' do
      given_i_am_on_the_home_page
      when_i_press_the_start_button
      when_i_confirm_i_have_a_trn_number
      when_i_press_continue
      when_i_fill_in_the_name_form
      then_i_see_the_date_of_birth_page

      when_i_press_back
      then_i_see_the_name_page
    end
  end

  context 'when the user has reached the have NI question' do
    it 'pressing back' do
      given_i_am_on_the_home_page
      when_i_press_the_start_button
      when_i_confirm_i_have_a_trn_number
      when_i_press_continue
      when_i_fill_in_the_name_form
      when_i_complete_my_date_of_birth
      then_i_see_the_have_ni_page

      when_i_press_back
      then_i_see_the_date_of_birth_page
    end
  end

  context 'when the user has reached the email question' do
    it 'pressing back' do
      given_i_am_on_the_home_page
      when_i_press_the_start_button
      when_i_confirm_i_have_a_trn_number
      when_i_press_continue
      when_i_fill_in_the_name_form
      when_i_complete_my_date_of_birth
      and_i_choose_no
      and_i_press_continue
      then_i_see_the_itt_provider_page

      when_i_choose_no
      and_i_press_continue
      then_i_see_the_email_page

      when_i_press_back
      then_i_see_the_itt_provider_page
    end
  end

  context 'when the user has reached the ITT provider question' do
    it 'pressing back' do
      given_i_am_on_the_home_page
      when_i_press_the_start_button
      when_i_confirm_i_have_a_trn_number
      when_i_press_continue
      when_i_fill_in_the_name_form
      when_i_complete_my_date_of_birth
      and_i_choose_no
      and_i_press_continue
      then_i_see_the_itt_provider_page

      when_i_press_back
      then_i_see_the_ni_page
    end
  end

  context 'when the user has reached the check answers page' do
    it 'pressing back' do
      given_i_have_completed_a_trn_request
      when_i_press_change_email
      and_i_press_back
      then_i_see_the_check_answers_page
      when_i_press_change_itt_provider
      then_i_see_the_itt_provider_page
      when_i_press_back
      then_i_see_the_check_answers_page
      when_i_press_change_ni_number
      then_i_see_the_have_ni_page
      when_i_press_back
      then_i_see_the_check_answers_page
    end
  end

  it 'refreshing the page and pressing back' do
    given_i_have_completed_a_trn_request
    when_i_press_change_email
    then_i_see_the_email_page

    when_i_refresh_the_page
    and_i_press_back
    then_i_see_the_check_answers_page
  end

  it 'ITT provider validations' do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_confirm_i_have_a_trn_number
    when_i_press_continue
    when_i_fill_in_the_name_form
    when_i_complete_my_date_of_birth
    then_i_see_the_ni_page

    when_i_choose_no
    and_i_press_continue
    then_i_see_the_itt_provider_page

    when_i_press_continue
    then_i_see_a_validation_error

    when_i_choose_yes
    and_i_press_continue
    then_i_see_a_validation_error
  end

  it 'no TRN' do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_choose_no_trn
    then_i_see_the_no_trn_page
  end

  it 'taking longer than usual' do
    given_it_is_taking_longer_than_usual
    when_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_confirm_i_have_a_trn_number
    when_i_press_continue
    then_i_see_the_taking_longer_page
    when_i_press_continue
    then_i_see_the_name_page
  end

  it 'service is closed' do
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

  context 'when the use_dqt_api feature is enabled' do
    it 'displays the TRN returned by the DQT API', vcr: true do
      given_the_use_dqt_api_feature_is_enabled
      when_i_have_completed_a_trn_request
      and_i_press_the_submit_button
      then_i_see_a_message_to_check_my_email
      and_i_receive_an_email_with_the_trn_number
    end
  end

  private

  def and_i_receive_an_email_with_the_trn_number
    open_email('kevin@kevin.com')
    expect(current_email.subject).to eq('Your TRN is 1275362')
  end

  def and_the_date_of_birth_is_prepopulated
    expect(page).to have_field('Day', with: '1')
    expect(page).to have_field('Month', with: '1')
    expect(page).to have_field('Year', with: '1990')
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
    when_i_fill_in_the_name_form
    when_i_complete_my_date_of_birth
    when_i_choose_no
    and_i_press_continue
    then_i_see_the_itt_provider_page

    when_i_choose_no
    and_i_press_continue
    then_i_see_the_email_page

    when_i_fill_in_my_email_address
    and_i_press_continue
  end
  alias_method :when_i_have_completed_a_trn_request, :given_i_have_completed_a_trn_request

  def given_it_is_taking_longer_than_usual
    FeatureFlag.activate(:processing_delays)
  end

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_the_service_is_closed
    FeatureFlag.deactivate(:service_open)
  end

  def given_the_use_dqt_api_feature_is_enabled
    FeatureFlag.activate(:use_dqt_api)
  end

  def then_i_see_a_message_to_check_my_email
    expect(page).to have_content('We have sent your TRN to')
  end

  def then_i_see_the_ask_questions_page
    expect(page).to have_current_path('/ask-questions')
    expect(page.driver.browser.current_title).to start_with('We’ll ask you some questions to help find your TRN')
    expect(page).to have_content('We’ll ask you some questions to help find your TRN')
  end

  def then_i_see_the_check_answers_page
    expect(page).to have_current_path('/check-answers')
    expect(page.driver.browser.current_title).to start_with('Check your answers')
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('Kevin E')
    expect(page).to have_content('kevin@kevin.com')
    expect(page).to have_content('Date of birth')
    expect(page).to have_content('01 January 1990')
  end

  def then_i_see_the_ni_missing_error
    expect(page).to have_content('Tell us if you have a National Insurance number')
  end

  def then_i_see_the_updated_itt_provider
    expect(page).to have_current_path('/check-answers')
    expect(page).to have_content('Where did you get your QTS?')
    expect(page).to have_content('Test ITT Provider')
  end

  def then_i_see_the_check_trn_page
    expect(page).to have_current_path('/check-trn')
    expect(page.driver.browser.current_title).to start_with('Check if you have a TRN')
    expect(page).to have_content('Check if you have a TRN')
  end

  def then_i_see_the_confirmation_page
    expect(page.driver.browser.current_title).to start_with('We’ve received your request')
    expect(page).to have_content('We’ve received your request')
  end

  def then_i_see_the_date_of_birth_page
    expect(page).to have_current_path('/date-of-birth')
    expect(page.driver.browser.current_title).to start_with('Your date of birth')
    expect(page).to have_content('Your date of birth')
  end
  alias_method :then_i_am_redirected_to_the_date_of_birth_page, :then_i_see_the_date_of_birth_page

  def then_i_see_the_email_page
    expect(page).to have_current_path('/email')
    expect(page.driver.browser.current_title).to start_with('Your email address')
    expect(page).to have_content('Your email address')
  end

  def then_i_see_the_existing_name
    expect(page).to have_field('First name', with: 'Kevin')
    expect(page).to have_field('Last name', with: 'E')
  end

  def then_i_see_the_home_page
    expect(page).to have_current_path(start_path)
    expect(page).to have_content('Find a lost teacher reference number (TRN)')
  end

  def then_i_see_the_itt_provider_page
    expect(page).to have_current_path('/itt-provider')
    expect(page.driver.browser.current_title).to start_with('Have you been awarded qualified teacher status (QTS)?')
    expect(page).to have_content('Have you been awarded qualified teacher status (QTS)?')
  end

  def then_i_see_the_have_ni_page
    expect(page).to have_current_path('/have-ni-number')
    expect(page.driver.browser.current_title).to start_with('Do you have a National Insurance number?')
    expect(page).to have_content('Do you have a National Insurance number?')
  end

  def then_i_see_the_name_page
    expect(page).to have_current_path('/name')
    expect(page.driver.browser.current_title).to start_with('Your name')
    expect(page).to have_content('Your name')
  end
  alias_method :then_i_am_redirected_to_the_name_page, :then_i_see_the_name_page

  def then_i_see_the_ni_page
    expect(page).to have_current_path('/have-ni-number')
    expect(page.driver.browser.current_title).to start_with('Do you have a National Insurance number?')
    expect(page).to have_content('Do you have a National Insurance number?')
  end

  def then_i_see_the_ni_number_page
    expect(page).to have_current_path('/ni-number')
    expect(page.driver.browser.current_title).to start_with('What is your National Insurance number?')
    expect(page).to have_content('What is your National Insurance number?')
  end

  def then_i_see_the_ni_number_missing_error
    expect(page).to have_content('Enter a National Insurance number')
  end

  def then_i_see_the_no_trn_page
    expect(page).to have_current_path('/you-dont-have-a-trn')
    expect(page.driver.browser.current_title).to start_with('You do not have a TRN')
    expect(page).to have_content('You don’t have a TRN')
  end

  def then_i_see_the_taking_longer_page
    expect(page).to have_current_path('/longer-than-normal')
  end

  def then_i_see_the_updated_email_address
    expect(page).to have_content('new@example.com')
  end

  def then_i_see_the_updated_name
    expect(page).to have_content('Kevin Smith')
  end

  def then_i_see_the_updated_ni_number
    expect(page).to have_content('QQ 12 34 56 C')
  end

  def then_i_see_a_validation_error
    expect(page).to have_content('There is a problem')
  end

  def then_i_should_see_the_home_page
    expect(page).to have_content('Find a lost teacher reference number')
  end

  def then_i_should_not_see_the_home_page
    expect(page).not_to have_content('Find a lost teacher reference number')
  end

  def then_no_should_be_checked
    expect(find_field('No', checked: true, visible: false)).to be_truthy
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

  def when_i_choose_no_trn
    choose 'No', visible: false
    when_i_press_continue
  end

  def when_i_confirm_i_have_a_trn_number
    choose 'Yes', visible: false
    when_i_press_continue
  end

  def when_i_enter_a_new_name
    fill_in 'First name', with: 'Kevin'
    fill_in 'Last name', with: 'Smith'
    check 'I’ve changed my name since I received my TRN', visible: false
    fill_in 'Previous last name', with: 'Evans'
    when_i_press_continue
  end

  def when_i_fill_in_the_name_form
    fill_in 'First name', with: 'Kevin'
    fill_in 'Last name', with: 'E'
    when_i_press_continue
  end

  def when_i_fill_in_my_itt_provider
    fill_in 'Where did you get your QTS?', with: 'Test ITT Provider', visible: false
  end
  alias_method :and_i_fill_in_my_itt_provider, :when_i_fill_in_my_itt_provider

  def when_i_fill_in_my_ni_number
    fill_in 'What is your National Insurance number?', with: 'QQ123456C'
  end
  alias_method :and_i_fill_in_my_ni_number, :when_i_fill_in_my_ni_number

  def when_i_choose_no
    choose 'No', visible: false
  end
  alias_method :and_i_choose_no, :when_i_choose_no

  def when_i_choose_yes
    choose 'Yes', visible: false
  end
  alias_method :and_i_choose_yes, :when_i_choose_yes

  def when_i_press_continue
    click_on 'Continue'
  end
  alias_method :and_i_press_continue, :when_i_press_continue

  def when_i_choose_yes_to_ni_number
    choose 'Yes', visible: false
    click_on 'Continue'
  end

  def when_i_enter_a_valid_ni_number
    fill_in 'What is your National Insurance number?', with: 'QQ123456C'
    click_on 'Continue'
  end

  def when_i_complete_my_date_of_birth
    fill_in 'Day', with: '01'
    fill_in 'Month', with: '01'
    fill_in 'Year', with: '1990'
    click_on 'Continue'
  end

  def when_i_press_back
    click_on 'Back'
  end
  alias_method :and_i_press_back, :when_i_press_back

  def when_i_fill_in_my_email_address
    fill_in 'Your email address', with: 'kevin@kevin.com'
  end
  alias_method :and_i_fill_in_my_email_address, :when_i_fill_in_my_email_address

  def when_i_fill_in_my_new_email_address
    fill_in 'Your email address', with: 'new@example.com'
  end
  alias_method :and_i_fill_in_my_new_email_address, :when_i_fill_in_my_new_email_address

  def when_i_press_change_date_of_birth
    click_on 'Change date of birth'
  end

  def when_i_press_change_email
    click_on 'Change email address'
  end

  def when_i_press_change_itt_provider
    click_on 'Change teacher training provider'
  end

  def when_i_press_change_name
    click_on 'Change name'
  end

  def when_i_press_change_ni_number
    click_on 'Change national insurance number'
  end

  def when_i_press_continue
    click_on 'Continue'
  end

  def when_i_press_the_start_button
    click_on 'Start now'
  end

  def when_i_press_the_submit_button
    click_on 'Submit'
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
    page.driver.basic_authorize('test', 'test')
  end
end
