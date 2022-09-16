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

  private

  def given_i_am_authorized_as_a_support_user
    page.driver.basic_authorize(
      ENV["SUPPORT_USERNAME"],
      ENV["SUPPORT_PASSWORD"],
    )
  end

  def when_i_visit_the_identity_users_support_page
    visit support_interface_identity_users_path
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
end
