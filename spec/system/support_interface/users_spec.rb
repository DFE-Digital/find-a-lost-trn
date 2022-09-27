require "rails_helper"

RSpec.describe "Identity Users Support", type: :system do
  user = {
    "userId" => "37ee5357-fb84-478e-b750-bf552e5c8eed",
    "email" => "kevin.e@example.com",
    "firstName" => "Kevin",
    "lastName" => "E",
    "dateOfBirth" => "1990-01-01",
    "trn" => nil,
  }

  it "displays a list of users", vcr: true, download: true do
    given_i_am_authorized_as_a_support_user
    when_i_visit_the_identity_users_support_page
    then_i_should_see_a_user
  end

  context "when there are more than 100 users" do
    before do
      users = 150.times.map { User.new(user) }
      allow(IdentityApi).to receive(:get_users).and_return(users)
    end

    it "shows the Identity users paginated" do
      given_i_am_authorized_as_a_support_user
      when_i_visit_the_identity_users_support_page
      and_i_should_see_page_1_navigation_links
      when_i_click_on_next
      then_i_should_see_page_2_navigation_links
    end
  end

  context "when there is an unverified user" do
    before do
      user["nameVerified"] = false
      allow(IdentityApi).to receive(:get_users).and_return([User.new(user)])
    end

    it "shows an unverified user" do
      given_i_am_authorized_as_a_support_user
      when_i_visit_the_identity_users_support_page
      then_i_should_see_an_unverified_user
    end
  end

  context "when there is an verified user" do
    before do
      user["nameVerified"] = true
      allow(IdentityApi).to receive(:get_users).and_return([User.new(user)])
    end

    it "shows an unverified user" do
      given_i_am_authorized_as_a_support_user
      when_i_visit_the_identity_users_support_page
      then_i_should_see_a_verified_user
    end
  end

  context "when the user does not have a DQT record" do
    before do
      user["trn"] = nil
      allow(IdentityApi).to receive(:get_users).and_return([User.new(user)])
    end

    it "shows a link to add a DQT record" do
      given_i_am_authorized_as_a_support_user
      when_i_visit_the_identity_users_support_page
      then_i_should_see_a_link_to_add_a_dqt_record
    end
  end

  context "when the user has a DQT record" do
    before do
      user["trn"] = "12345"
      allow(IdentityApi).to receive(:get_users).and_return([User.new(user)])
    end

    it "shows a link to add a DQT record" do
      given_i_am_authorized_as_a_support_user
      when_i_visit_the_identity_users_support_page
      then_i_should_not_see_a_link_to_add_a_dqt_record
    end
  end

  context "When user attempts to match identity record to a DQT record" do
    before do
      user["trn"] = nil
      allow(IdentityApi).to receive(:get_users).and_return([User.new(user)])
    end

    it "shows the add TRN page", vcr: true do
      given_i_am_authorized_as_a_support_user
      when_i_visit_the_identity_users_support_page
      and_i_proceed_to_add_a_dqt_record
      then_i_should_see_the_add_trn_page
    end

    context "valid trn" do
      it "redirects to the confirmation page", vcr: true do
        given_i_am_authorized_as_a_support_user
        when_i_visit_the_identity_users_support_page
        and_i_proceed_to_add_a_dqt_record
        and_i_add_a_trn
        and_i_click_continue
        then_i_should_see_the_confirmation_page
      end
    end

    context "invalid trn" do
      it "redirects to the confirmation page", vcr: true do
        given_i_am_authorized_as_a_support_user
        when_i_visit_the_identity_users_support_page
        and_i_proceed_to_add_a_dqt_record
        and_i_add_an_invalid_trn
        and_i_click_continue
        then_i_should_see_an_error_message
      end
    end

    it "links DQT record when user accepts confirmation", vcr: true do
      given_i_am_authorized_as_a_support_user
      when_i_visit_the_identity_users_support_page
      and_i_confirm_addition_of_a_dqt_record
      then_the_dqt_record_should_be_linked
    end

    it "Does not link DQT record when user rejects confirmation", vcr: true do
      given_i_am_authorized_as_a_support_user
      when_i_visit_the_identity_users_support_page
      and_i_reject_addition_of_a_dqt_record
      then_the_dqt_record_should_not_be_linked
    end

    it "Asks user to select an option if they have non selected", vcr: true do
      given_i_am_authorized_as_a_support_user
      when_i_visit_the_identity_users_support_page
      and_i_proceed_to_add_a_dqt_record
      and_i_add_a_trn
      and_i_click_continue
      then_i_should_see_the_confirmation_page
      and_i_click_continue
      then_i_should_be_asked_to_select_an_option
    end

    it "Navigates us to the previous page", vcr: true do
      given_i_am_authorized_as_a_support_user
      when_i_visit_the_identity_users_support_page
      and_i_proceed_to_add_a_dqt_record
      and_i_press_the_back_link
      then_i_should_be_on_the_identity_users_support_page
    end
  end

  private

  def given_i_am_authorized_as_a_support_user
    page.driver.basic_authorize(
      ENV["SUPPORT_USERNAME"],
      ENV["SUPPORT_PASSWORD"],
    )
  end

  def when_i_visit_the_identity_users_support_page
    visit support_interface_identity_user_index_path
  end

  def then_i_should_see_a_user
    expect(page).to have_content "Jane Doess"
  end

  def then_i_should_see_an_unverified_user
    expect(page).to have_content "UNVERIFIED"
  end

  def then_i_should_see_a_verified_user
    expect(page).to have_content "VERIFIED"
  end

  def then_i_should_see_a_link_to_add_a_dqt_record
    expect(page).to have_link "Add a DQT record"
  end

  def then_i_should_not_see_a_link_to_add_a_dqt_record
    expect(page).to_not have_link "Add a DQT record"
  end

  def when_i_click_on_next
    # There are top and bottom page navigation menus
    first("a", text: "Next").click
  end

  def and_i_press_the_back_link
    first("a", text: "Back").click
  end

  def and_i_should_see_page_1_navigation_links
    expect(page).to have_link("1")
    expect(page).to have_link("2")
    expect(page).to have_link("Next")
    expect(page).to_not have_link("Prev")
  end

  def then_i_should_see_page_2_navigation_links
    expect(page).to have_link("1")
    expect(page).to have_link("2")
    expect(page).to have_link("Prev")
    expect(page).to_not have_link("Next")
  end

  def when_i_proceed_to_add_a_dqt_record
    click_on "Add a DQT record"
  end
  alias_method :and_i_proceed_to_add_a_dqt_record,
               :when_i_proceed_to_add_a_dqt_record

  def then_i_should_see_the_add_trn_page
    expect(page).to have_content(
      "What is their teacher reference number (TRN)?",
    )
  end

  def and_i_add_a_trn
    fill_in "What is their teacher reference number (TRN)?", with: "2921020"
  end

  def and_i_add_an_invalid_trn
    fill_in "What is their teacher reference number (TRN)?",
            with: "292102012345"
  end

  def then_i_should_see_an_error_message
    within(".govuk-error-summary") do
      expect(page).to have_content("There is a problem")
      expect(page).to have_content(
        "is the wrong length (should be 7 characters)",
      )
    end
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def and_i_confirm_addition_of_a_dqt_record
    when_i_proceed_to_add_a_dqt_record
    and_i_add_a_trn
    and_i_click_continue
    choose "Yes, add this record", visible: false
    and_i_click_continue
    expect(page).to have_content("DQT Record added")
  end

  def and_i_reject_addition_of_a_dqt_record
    when_i_proceed_to_add_a_dqt_record
    and_i_add_a_trn
    and_i_click_continue
    choose "No, this is the wrong record", visible: false
    and_i_click_continue
    expect(page).to_not have_content("DQT Record added")
  end

  def then_the_dqt_record_should_be_linked
    within all(".app-govuk-summary-card").last do
      within(".app-govuk-summary-card__header") do
        expect(page).to have_content "DQT record"
      end
      expect(page).to have_content "Official name"
      expect(page).to have_content "Kevin E"
      expect(page).to have_content "Date of birth"
      expect(page).to have_content "1 January 1990"
      expect(page).to have_content "National insurance number"
      expect(page).to have_content "Given"
      expect(page).to have_content "TRN"
      expect(page).to have_content "2921020"
    end
    then_i_should_not_see_a_link_to_add_a_dqt_record
  end

  def then_the_dqt_record_should_not_be_linked
    within all(".app-govuk-summary-card__header").last do
      expect(page).to_not have_content "DQT record"
    end
    expect(page).to have_link("Add record")
  end

  def then_i_should_see_the_confirmation_page
    within(".govuk-heading-xl") do
      expect(page).to have_content(
        "We found a DQT record, is it the right one?",
      )
    end
  end

  def then_i_should_be_asked_to_select_an_option
    within(".govuk-error-message") do
      expect(page).to have_content("Tell us if this is the right DQT record")
    end
  end

  def then_i_should_be_on_the_identity_users_support_page
    expect(current_path).to eq(support_interface_identity_user_index_path)
  end
end
