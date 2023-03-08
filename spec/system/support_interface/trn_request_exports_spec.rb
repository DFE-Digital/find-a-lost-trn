require "rails_helper"

RSpec.feature "Trn Request exports", type: :system do
  before do
    travel_to Time.zone.local(2022, 11, 18, 12, 0, 0)
    given_the_service_is_open
  end

  after do
    travel_back
    deactivate_feature_flags
  end

  scenario "Exporting TRN requests", download: true do
    given_there_is_a_trn_request
    and_i_am_authorized_as_a_support_user
    and_i_am_on_the_trn_requests_page
    when_i_select_the_time_period
    and_i_click_the_export_button
    then_the_exported_file_should_contain_the_trn_request
  end

  private

  def and_i_am_authorized_as_a_support_user
    page.driver.basic_authorize("test", "test")
  end

  def and_i_am_on_the_trn_requests_page
    visit support_interface_trn_requests_path
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

  def given_there_is_a_trn_request
    @trn_request =
      create(:trn_request, email: "trn@example.com", id: 1, trn: "123456")
  end

  def then_the_exported_file_should_contain_the_trn_request
    expect(page.response_headers["Content-Disposition"]).to eq(
      "attachment; filename=\"2022_11_30_trn_requests.csv\"; " \
        "filename*=UTF-8''2022_11_30_trn_requests.csv",
    )
    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(download_content).to eq(
      "Id,Trn,Email,First Unlocked At,Created At,Updated At\n" \
        "1,123456,trn@example.com,,2022-11-18 12:00:00 UTC,2022-11-18 12:00:00 UTC\n",
    )
  end

  def when_i_select_the_time_period
    select "November 2022",
           from: "Which month do you want to export?",
           visible: false
  end
end
