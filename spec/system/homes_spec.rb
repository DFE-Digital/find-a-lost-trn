# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Home', type: :system do
  it 'visiting the start page' do
    when_i_visit_the_home_page
    then_i_see_the_home_page
  end

  private

  def then_i_see_the_home_page
    expect(page).to have_content('Find a lost teacher reference number (TRN)')
  end

  def when_i_visit_the_home_page
    visit root_path
  end
end
