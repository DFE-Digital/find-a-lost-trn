# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Validation errors', type: :system do
  it 'using the validation errors UI' do
    given_the_service_is_open
    given_there_are_a_few_validation_errors
    when_i_am_authorized_as_a_support_user
    when_i_visit_the_validation_errors_page
    then_i_see_the_validation_errors

    when_i_click_the_link_of_the_first_error_group
    then_i_see_the_details_of_the_first_error_group
  end

  private

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_there_are_a_few_validation_errors
    FeatureFlag.activate(:log_validation_errors)

    create(:trn_request).tap do |trn_request|
      trn_request.first_name = nil
      NameForm.new(trn_request: trn_request).save
    end

    create(:trn_request).tap do |trn_request|
      trn_request.last_name = nil
      NameForm.new(trn_request: trn_request).save
    end

    create(:trn_request).tap do |trn_request|
      DateOfBirthForm
        .new(trn_request: trn_request)
        .update('date_of_birth(1i)' => nil, 'date_of_birth(2i)' => nil, 'date_of_birth(3i)' => nil)
    end
  end

  def then_i_see_the_details_of_the_first_error_group
    expect(page).to have_content 'Enter your first name'
    expect(page).to have_content 'Enter your last name'
  end

  def then_i_see_the_validation_errors
    expect(page).to have_content 'Validation errors'
    expect(page).to have_content 'NameForm'
    expect(page).to have_content '2'
  end

  def when_i_am_authorized_as_a_support_user
    page.driver.basic_authorize('test', 'test')
  end

  def when_i_click_the_link_of_the_first_error_group
    click_link 'NameForm'
  end

  def when_i_visit_the_validation_errors_page
    visit support_interface_validation_errors_path
  end
end
