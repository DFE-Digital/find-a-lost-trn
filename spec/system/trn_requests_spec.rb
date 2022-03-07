# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'TRN requests', type: :system do
  it 'completing a request' do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
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
  end

  it 'entering the NI number' do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
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

  it 'pressing back' do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_press_back
    then_i_see_the_home_page
  end

  context 'when the user has reached the email question' do
    it 'pressing back' do
      given_i_am_on_the_home_page
      when_i_press_the_start_button
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

  private

  def given_i_am_on_the_home_page
    visit root_path
  end

  def given_i_have_completed_a_trn_request
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    when_i_choose_no
    and_i_press_continue
    then_i_see_the_itt_provider_page

    when_i_choose_no
    and_i_press_continue
    then_i_see_the_email_page

    when_i_fill_in_my_email_address
    and_i_press_continue
  end

  def then_i_see_the_check_answers_page
    expect(page).to have_current_path('/check-answers')
    expect(page.driver.browser.current_title).to start_with('Check your answers')
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('email@example.com')
  end

  def then_i_see_the_ni_missing_error
    expect(page).to have_content('Tell us if you have a National Insurance number')
  end

  def then_i_see_the_updated_itt_provider
    expect(page).to have_current_path('/check-answers')
    expect(page).to have_content('Teacher training provider')
    expect(page).to have_content('Test ITT Provider')
  end

  def then_i_see_the_confirmation_page
    expect(page.driver.browser.current_title).to start_with('Information Received')
    expect(page).to have_content('Information received')
  end

  def then_i_see_the_email_page
    expect(page).to have_current_path('/email')
    expect(page.driver.browser.current_title).to start_with('Your email address')
    expect(page).to have_content('Your email address')
  end

  def then_i_see_the_home_page
    expect(page).to have_current_path(start_path)
    expect(page).to have_content('Find a lost teacher reference number (TRN)')
  end

  def then_i_see_the_itt_provider_page
    expect(page).to have_current_path('/itt-provider')
    expect(page.driver.browser.current_title).to start_with(
      'Have you ever been enrolled in initial teacher training in England or Wales?',
    )
    expect(page).to have_content('Have you ever been enrolled in initial teacher training in England or Wales?')
  end

  def then_i_see_the_have_ni_page
    expect(page).to have_current_path('/have-ni-number')
    expect(page.driver.browser.current_title).to start_with('Do you have a National Insurance number?')
    expect(page).to have_content('Do you have a National Insurance number?')
  end

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

  def then_i_see_the_updated_email_address
    expect(page).to have_content('new@example.com')
  end

  def then_i_see_the_updated_ni_number
    expect(page).to have_content('QQ 12 34 56 C')
  end

  def then_i_see_a_validation_error
    expect(page).to have_content('There is a problem')
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
    when_i_choose_no_ni_number
    when_i_choose_no_itt_provider
  end

  def when_i_fill_in_my_itt_provider
    fill_in 'Your school, university or other training provider', with: 'Test ITT Provider', visible: false
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

  def when_i_press_back
    click_on 'Back'
  end
  alias_method :and_i_press_back, :when_i_press_back

  def when_i_fill_in_my_email_address
    fill_in 'Your email address', with: 'email@example.com'
  end
  alias_method :and_i_fill_in_my_email_address, :when_i_fill_in_my_email_address

  def when_i_fill_in_my_new_email_address
    fill_in 'Your email address', with: 'new@example.com'
  end
  alias_method :and_i_fill_in_my_new_email_address, :when_i_fill_in_my_new_email_address

  def when_i_press_change_email
    click_on 'Change email address'
  end

  def when_i_press_change_itt_provider
    click_on 'Change teacher training provider'
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

  def when_i_refresh_the_page
    page.driver.browser.refresh
  end

  def when_i_try_to_go_straight_to_the_confirmation_page
    visit helpdesk_request_submitted_path
  end

  def when_i_try_to_go_to_the_check_answers_page
    visit trn_request_path
  end
end
