# frozen_string_literal: true
require "rails_helper"

RSpec.describe "TPS contact banner", type: :system do
  before { given_the_service_is_open }

  it "shows the TPS contact details while the banner is active" do
    given_the_tps_contact_banner_is_active
    when_i_visit_the_start_page
    then_i_see_the_tps_contact_details
  end

  it "hides the banner while it's inactive" do
    when_i_visit_the_start_page
    then_i_see_no_banner
  end

  private

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_the_tps_contact_banner_is_active
    FeatureFlag.activate(:tps_contact_banner)
  end

  def when_i_visit_the_start_page
    visit root_path
  end

  def then_i_see_the_tps_contact_details
    banner = find(".govuk-notification-banner")

    aggregate_failures do
      expect(banner).to have_content("Important")
      expect(banner).to have_content(
        "Due to current issues on the Teachers’ Pension Portal, please " \
          "contact them directly",
      )
      expect(banner).to have_content("Telephone: 0345 6066166")
      expect(banner).to have_content("international call +44 1227 213243")
    end
  end

  def then_i_see_no_banner
    # The heading first, so the absence check runs against the loaded page.
    expect(page).to have_css("h1", text: "Find a lost teacher reference number")
    expect(page).to have_no_css(".govuk-notification-banner")
  end
end
