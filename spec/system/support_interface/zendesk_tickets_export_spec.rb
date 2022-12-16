require "rails_helper"

RSpec.feature "Zendesk ticket exports", type: :system do
  before do
    travel_to Time.zone.local(2022, 12, 18, 12, 0, 0)
    given_the_service_is_open
  end

  after do
    travel_back
    deactivate_feature_flags
  end

  scenario "Exporting deleted tickets", download: true do
    given_there_is_a_deleted_zendesk_ticket
    and_i_am_authorized_as_a_support_user
    and_i_am_on_the_zendesk_tickets_page
    when_i_select_the_time_period
    and_i_click_the_export_button
    then_the_exported_file_should_contain_the_deleted_ticket
  end

  private

  def and_i_am_authorized_as_a_support_user
    page.driver.basic_authorize("test", "test")
  end

  def and_i_am_on_the_zendesk_tickets_page
    visit support_interface_zendesk_path
  end

  def and_i_click_the_export_button
    click_on "Export to CSV"
  end

  def deactivate_feature_flags
    FeatureFlag.deactivate(:service_open)
  end

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_there_is_a_deleted_zendesk_ticket
    create(
      :zendesk_delete_request,
      ticket_id: 1,
      closed_at: Time.zone.local(2022, 12, 1, 12, 0, 0),
    )
    create(
      :zendesk_delete_request,
      ticket_id: 1,
      closed_at: Time.zone.local(2022, 11, 1, 12, 0, 0),
    )
  end

  def then_the_exported_file_should_contain_the_deleted_ticket
    expect(page.response_headers["Content-Disposition"]).to eq(
      "attachment; filename=\"2022_11_01_deleted_zendesk_tickets.csv\"; " \
        "filename*=UTF-8''2022_11_01_deleted_zendesk_tickets.csv",
    )
    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(download_content).to eq(
      "Ticket,Group Name,Received At,Closed At,Enquiry Type,No Action Required\n" \
        "1,QTS Enquiries,2022-06-05 13:00,2022-11-01 12:00,Trn,\n",
    )
  end

  def when_i_select_the_time_period
    select "November 2022",
           from: "Which month do you want to export?",
           visible: false
  end
end
