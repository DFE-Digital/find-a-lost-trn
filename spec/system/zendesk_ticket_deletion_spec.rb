require "rails_helper"

RSpec.describe "Zendesk ticket deletion", type: :system do
  before { given_the_service_is_open }
  after { deactivate_feature_flags }

  it "allows deleting outstanding Zendesk tickets", vcr: true do
    given_i_am_authorized_as_a_support_user
    when_i_visit_the_zendesk_support_page
    then_i_should_see_a_ticket

    when_i_click_start
    then_i_should_see_the_confirmation_page

    when_i_submit
    then_i_should_see_a_validation_error

    when_i_enter_the_number_of_tickets
    and_i_submit
    then_i_should_see_a_success_banner
    and_a_job_to_delete_tickets_is_queued
  end

  context "when there are Zendesk tickets that have been requested for deletion" do
    before do
      # Create Zendesk deletion requests for 2 pages (100 per page)
      150.times do |cntr|
        ZendeskDeleteRequest.create(
          ticket_id: cntr + 42,
          received_at: Time.zone.now,
          closed_at: Time.zone.now,
          group_name: "delete request group"
        )
      end
    end

    it "shows the Zendesk delete requests paginated" do
      given_i_am_authorized_as_a_support_user
      when_i_visit_the_zendesk_support_page
      then_i_should_see_the_latest_delete_request
      and_i_should_see_page_1_navigation_links
      when_i_click_on_next
      then_i_should_see_page_2_navigation_links
      and_i_should_see_the_last_delete_request
    end

    it "exports Zendesk tickets that have been requested for deletion" do
      given_i_am_authorized_as_a_support_user
      when_i_visit_the_zendesk_support_page
      then_i_should_see_the_latest_delete_request
      and_i_should_be_able_to_export_tickets_to_csv
    end
  end

  private

  def deactivate_feature_flags
    FeatureFlag.deactivate(:service_open)
  end

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_i_am_authorized_as_a_support_user
    page.driver.basic_authorize(
      ENV["SUPPORT_USERNAME"],
      ENV["SUPPORT_PASSWORD"]
    )
  end

  def when_i_visit_the_zendesk_support_page
    visit support_interface_zendesk_path
  end

  def when_i_click_start
    click_on "Start"
  end

  def when_i_submit
    click_on "Delete 1 tickets"
  end
  alias_method :and_i_submit, :when_i_submit

  def when_i_enter_the_number_of_tickets
    fill_in "Number of tickets to delete", with: 1
  end

  def then_i_should_see_a_ticket
    expect(page).to have_content "Ticket 42"
  end

  def then_i_should_see_the_confirmation_page
    expect(page).to have_content "Delete 1 Zendesk tickets"
  end

  def then_i_should_see_a_validation_error
    expect(page).to have_content "Error"
  end

  def then_i_should_see_a_success_banner
    expect(page).to have_content "Success"
  end

  def and_a_job_to_delete_tickets_is_queued
    expect(DeleteOldZendeskTicketsJob).to have_been_enqueued
  end

  def then_i_should_see_the_latest_delete_request
    expect(page).to have_content "Ticket 191"
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

  def and_i_should_see_the_last_delete_request
    expect(page).to have_content("Ticket 43")
  end

  def and_i_should_be_able_to_export_tickets_to_csv
    click_on("Export to CSV")
    expect(download_content).to eq(ZendeskDeleteRequest.to_csv)
  end
end
