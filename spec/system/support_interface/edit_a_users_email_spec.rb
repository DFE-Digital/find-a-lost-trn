# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Edit a user's email in support", vcr: true, type: :system do
  it "updates the user's email address" do
    given_i_am_authorized_as_staff
    and_a_user_exists_on_the_identity_api
    when_i_navigate_to_the_user_show_page_in_support
    then_i_can_see_the_users_details
    and_i_can_see_a_link_to_change_their_email
    when_i_click_change_email
    and_i_fill_in_a_different_email
    then_i_can_see_their_email_was_successfully_updated
  end

  private

  def given_i_am_authorized_as_staff
    page.driver.basic_authorize("test", "test")
  end

  def and_a_user_exists_on_the_identity_api
    @uuid = "29e9e624-073e-41f5-b1b3-8164ce3a5233"
    @email = "kevin.e@digital.education.gov.uk"
    @user =
      User.new(
        "userId" => @uuid,
        "firstName" => "Kevin",
        "lastName" => "E",
        "email" => @email,
      )

    allow(DqtApi).to receive(:find_teacher_by_trn!)
  end

  def when_i_navigate_to_the_user_show_page_in_support
    visit support_interface_identity_user_path(@uuid)
  end

  def then_i_can_see_the_users_details
    expect(current_path).to eq support_interface_identity_user_path(@uuid)
    within first(".app-govuk-summary-card") do
      within(".app-govuk-summary-card__header") do
        expect(page).to have_content "Get an identity details"
      end
      expect(page).to have_content "Kevin E"
      expect(page).to have_content @email
    end
  end

  def and_i_can_see_a_link_to_change_their_email
    within first(".app-govuk-summary-card") do
      expect(page).to have_link "Change email address"
    end
  end

  def when_i_click_change_email
    within first(".app-govuk-summary-card") do
      click_on "Change email address"
    end
  end

  def and_i_fill_in_a_different_email
    fill_in "Change email address", with: "kev.ine@digital.eduction.gov.uk"
    click_on "Continue"
  end

  def then_i_can_see_their_email_was_successfully_updated
    expect(page).to have_content "Email changed successfully"
    within first(".app-govuk-summary-card") do
      expect(page).to have_content "kev.ine@digital.education.gov.uk"
    end
  end
end
