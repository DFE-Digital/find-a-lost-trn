# frozen_string_literal: true
require "rails_helper"

RSpec.describe "View a teacher in support", type: :system do
  scenario "Support user views teacher details" do
    given_i_am_authorized_as_a_support_user
    and_a_teacher_exists_on_the_identity_api
    when_i_navigate_to_the_teachers_page_in_support
    then_i_can_see_the_teachers_details
  end

  private

  def given_i_am_authorized_as_a_support_user
    page.driver.basic_authorize("test", "test")
  end

  def and_a_teacher_exists_on_the_identity_api
    # Use an arbitrary uuid value for now. Once the required API endpoint is implemented,
    # this should match the value used in a recorded VCR cassette.
    @uuid = "any-uuid"
  end

  def when_i_navigate_to_the_teachers_page_in_support
    visit support_interface_teacher_path(@uuid)
  end

  def then_i_can_see_the_teachers_details
    expect(current_path).to eq support_interface_teacher_path(@uuid)
    within(".x-govuk-summary-card") do
      within(".x-govuk-summary-card__header") do
        expect(page).to have_content "Get an identity details"
      end
      expect(page).to have_content "Kevin E"
      expect(page).to have_content "kevin.e@digital.education.gov.uk"
    end
  end
end
