# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Support', type: :system do
  it 'visiting the support interface' do
    when_i_am_authorized_as_a_support_user
    and_i_visit_the_support_page
    then_i_see_the_trn_requests_page
  end

  private

  def when_i_am_authorized_as_a_support_user
    page.driver.basic_authorize('test', 'test')
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def then_i_see_the_trn_requests_page
    expect(page).to have_content('TRN Requests')
  end
end
