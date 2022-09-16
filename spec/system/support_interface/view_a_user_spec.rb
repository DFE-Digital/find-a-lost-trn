# frozen_string_literal: true
require "rails_helper"

RSpec.describe "View a user in support", type: :system do
  scenario "Staff user views user details" do
    given_i_am_authorized_as_staff
    and_a_user_exists_on_the_identity_api
    when_i_navigate_to_the_user_show_page_in_support
    then_i_can_see_the_users_details
  end

  private

  def given_i_am_authorized_as_staff
    page.driver.basic_authorize("test", "test")
  end

  def and_a_user_exists_on_the_identity_api
    # Use an arbitrary uuid value for now. Once the required API endpoint is implemented,
    # this should match the value used in a recorded VCR cassette.
    @uuid = "any-uuid"
  end

  def when_i_navigate_to_the_user_show_page_in_support
    visit support_interface_user_path(@uuid)
  end

  def then_i_can_see_the_users_details
    expect(current_path).to eq support_interface_user_path(@uuid)
    within(".x-govuk-summary-card") do
      within(".x-govuk-summary-card__header") do
        expect(page).to have_content "Get an identity details"
      end
      expect(page).to have_content "Kevin E"
      expect(page).to have_content "kevin.e@digital.education.gov.uk"
    end
  end
end
