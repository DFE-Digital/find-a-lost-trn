# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'TRN requests', type: :system do
  it 'completing a request' do
    given_i_am_on_the_home_page
    when_i_try_to_go_straight_to_the_confirmation_page
    then_i_am_redirected_to_home
    when_i_press_the_start_button
    then_i_see_the_confirmation_page
  end

  private

  def given_i_am_on_the_home_page
    visit root_path
  end

  def then_i_am_redirected_to_home
    expect(page).to have_current_path(start_path)
    expect(page).to have_content('Find a lost teacher reference number (TRN)')
  end

  def then_i_see_the_confirmation_page
    expect(page.driver.browser.current_title).to start_with('Information Received')
    expect(page).to have_content('Information received')
  end

  def when_i_press_the_start_button
    click_on 'Start now'
  end

  def when_i_try_to_go_straight_to_the_confirmation_page
    visit helpdesk_request_submitted_path
  end
end
