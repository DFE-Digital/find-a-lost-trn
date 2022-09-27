# frozen_string_literal: true
require "rails_helper"

RSpec.describe "User page in support", vcr: true, type: :system do
  it "displays the user" do
    given_i_am_authorized_as_staff
    and_a_user_exists_on_the_identity_api
    when_i_navigate_to_the_user_show_page_in_support
    then_i_can_see_the_users_details
    and_i_can_see_the_users_dqt_details
    and_i_can_see_a_link_to_change_the_dqt_record
  end

  context "when the user has no DQT record", vcr: true do
    before do
      given_i_am_authorized_as_staff
      and_a_user_exists_on_the_identity_api
      when_i_navigate_to_the_user_show_page_in_support
    end

    it "does not show a DQT section" do
      then_i_cannot_see_the_users_dqt_section
    end

    it "when_i_click_on_add_record" do
      and_i_click_on_add_record
      then_i_see_an_add_dqt_success_message
      and_i_can_see_the_users_dqt_details
    end
  end

  private

  def given_i_am_authorized_as_staff
    page.driver.basic_authorize("test", "test")
  end

  def and_a_user_exists_on_the_identity_api
    # Matches uuid value used in VCR cassette
    @uuid = "29e9e624-073e-41f5-b1b3-8164ce3a5233"
  end

  def when_i_navigate_to_the_user_show_page_in_support
    visit support_interface_user_path(@uuid)
  end

  def then_i_can_see_the_users_details
    expect(current_path).to eq support_interface_user_path(@uuid)
    within first(".app-govuk-summary-card") do
      within(".app-govuk-summary-card__header") do
        expect(page).to have_content "Get an identity details"
      end
      expect(page).to have_content "Kevin E"
      expect(page).to have_content "kevin.e@digital.education.gov.uk"
    end
  end

  def and_i_can_see_the_users_dqt_details
    within all(".app-govuk-summary-card").last do
      within(".app-govuk-summary-card__header") do
        expect(page).to have_content "DQT record"
      end
      within(".govuk-summary-list") do
        expect(page).to have_content "Official name"
        expect(page).to have_content "Kevin E"
        expect(page).to have_content "Date of birth"
        expect(page).to have_content "1 January 1990"
        expect(page).to have_content "National insurance number"
        expect(page).to have_content "Given"
        expect(page).to have_content "TRN"
        expect(page).to have_content "2921020"
      end
    end
  end

  def and_i_can_see_a_link_to_change_the_dqt_record
    within first(".app-govuk-summary-card") do
      expect(page).to have_link "Change record"
    end
  end

  def then_i_cannot_see_the_users_dqt_section
    within all(".app-govuk-summary-card__header").last do
      expect(page).to_not have_content "DQT record"
    end
  end

  def and_i_click_on_add_record
    click_on "Add record"
  end

  def then_i_see_an_add_dqt_success_message
    expect(page).to have_content("DQT record added")
  end
end
