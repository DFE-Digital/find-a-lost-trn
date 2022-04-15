# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Support', type: :system do
  it 'using the support interface' do
    given_there_is_a_trn_request_in_progress
    when_i_am_authorized_as_a_support_user
    and_i_visit_the_support_page
    then_i_see_the_trn_requests_page
    and_there_is_a_trn_request_in_progress

    when_i_visit_the_feature_flags_page
    then_i_see_the_feature_flags

    when_i_activate_the_zendesk_feature_flag
    then_the_zendesk_flag_is_on

    when_i_deactivate_the_zendesk_feature_flag
    then_the_zendesk_flag_is_off
  end

  private

  def given_there_is_a_trn_request_in_progress
    create(:trn_request)
  end

  def when_i_am_authorized_as_a_support_user
    page.driver.basic_authorize('test', 'test')
  end

  def when_i_visit_the_feature_flags_page
    click_on 'Features'
  end

  def when_i_activate_the_zendesk_feature_flag
    click_on 'Activate Zendesk integration'
  end

  def when_i_deactivate_the_zendesk_feature_flag
    click_on 'Deactivate Zendesk integration'
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def then_i_see_the_trn_requests_page
    expect(page).to have_content('TRN Requests')
  end

  def then_i_see_the_feature_flags
    expect(page).to have_content('Features')
  end

  def then_the_zendesk_flag_is_on
    expect(page).to have_content('Feature “Zendesk integration” activated')
    expect(page).to have_content("Zendesk integration\n- Active")
  end

  def then_the_zendesk_flag_is_off
    expect(page).to have_content('Feature “Zendesk integration” deactivated')
    expect(page).to have_content("Zendesk integration\n- Inactive")
  end

  def and_there_is_a_trn_request_in_progress
    trn_request = TrnRequest.last
    expect(page).to have_content("TRN Request ##{trn_request.id}")
    expect(page).to have_content(trn_request.name.to_s)
    expect(page).to have_content('NOT YET SUBMITTED')
  end
end
