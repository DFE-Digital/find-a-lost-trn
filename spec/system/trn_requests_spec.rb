# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'TRN requests', type: :system do
  it 'completing a request' do
    given_i_am_on_the_home_page
    when_i_press_the_start_button
    then_i_see_the_itt_provider_page
    when_i_choose_no_itt_provider
    then_i_see_the_email_page
    when_i_submit_my_email_address
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

  it 'changing my email address' do
    given_i_have_completed_a_trn_request
    when_i_change_my_email
    then_i_see_the_updated_email_address
  end

  it 'changing my ITT provider' do
    given_i_have_completed_a_trn_request
    when_i_change_my_itt_provider
    then_i_see_the_updated_itt_provider
  end

  it 'pressing back' do
    given_i_am_on_the_itt_provider_page
    when_i_press_back
    then_i_see_the_home_page
    when_i_am_on_the_email_page
    when_i_press_back
    then_i_see_the_home_page
    when_i_am_on_the_check_answers_page
    when_i_press_back
    then_i_see_the_home_page
    when_i_try_to_go_to_the_check_answers_page
    when_i_press_change_email
    and_i_press_back
    then_i_see_the_check_answers_page
    when_i_press_change_itt_provider
    then_i_see_the_itt_provider_page
    when_i_press_back
    then_i_see_the_check_answers_page
  end

  it 'refreshing the page and pressing back' do
    given_i_have_completed_a_trn_request
    when_i_press_change_email
    then_i_see_the_email_page
    when_i_refresh_the_page
    and_i_press_back
    then_i_see_the_check_answers_page
  end

  private

  def given_i_am_on_the_home_page
    visit root_path
  end

  def given_i_am_on_the_itt_provider_page
    visit root_path
    click_on 'Start'
  end

  def given_i_have_completed_a_trn_request
    visit root_path
    click_on 'Start'
    choose 'No', visible: false
    click_on 'Continue'
    fill_in 'Your email address', with: 'email@example.com'
    click_on 'Continue'
  end

  def then_i_see_the_check_answers_page
    expect(page).to have_current_path('/check-answers')
    expect(page.driver.browser.current_title).to start_with('Check your answers')
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('email@example.com')
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

  def then_i_see_the_updated_email_address
    expect(page).to have_content('new@example.com')
  end

  def when_i_am_on_the_check_answers_page
    given_i_have_completed_a_trn_request
  end

  def when_i_am_on_the_email_page
    visit root_path
    click_on 'Start now'
    choose 'No', visible: false
    click_on 'Continue'
  end

  def when_i_change_my_email
    click_on 'Change email'
    fill_in 'Your email address', with: 'new@example.com'
    click_on 'Continue'
  end

  def when_i_change_my_itt_provider
    click_on 'Change itt_provider'
    choose 'Yes', visible: false
    fill_in 'Your school, university or other training provider', with: 'Test ITT Provider', visible: false
    click_on 'Continue'
  end

  def when_i_choose_no_itt_provider
    choose 'No', visible: false
    click_on 'Continue'
  end

  def when_i_press_back
    click_on 'Back'
  end
  alias_method :and_i_press_back, :when_i_press_back

  def when_i_press_change_email
    click_on 'Change email'
  end

  def when_i_press_change_itt_provider
    click_on 'Change itt_provider'
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

  def when_i_submit_my_email_address
    fill_in 'Your email address', with: 'email@example.com'
    click_on 'Continue'
  end

  def when_i_try_to_go_straight_to_the_confirmation_page
    visit helpdesk_request_submitted_path
  end

  def when_i_try_to_go_to_the_check_answers_page
    visit trn_request_path
  end
end
