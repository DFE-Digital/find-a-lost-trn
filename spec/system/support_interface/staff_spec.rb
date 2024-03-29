require "rails_helper"

RSpec.describe "Staff support", type: :system do
  it "allows inviting a user" do
    given_the_service_is_open
    given_the_service_is_staff_http_basic_auth

    when_i_am_authorized_as_a_support_user
    when_i_visit_the_staff_page
    then_i_see_the_staff_index

    when_i_click_on_invite
    then_i_see_the_staff_invitation_form

    when_i_fill_email_address
    and_i_send_invitation
    then_i_see_an_invitation_email
    then_i_see_the_staff_index
    then_i_see_the_invited_staff_user

    when_i_visit_the_invitation_email
    and_i_fill_password
    and_i_set_password
    then_i_see_the_staff_index

    then_i_see_the_accepted_staff_user
  end

  it "allows authenticating staff using Identity" do
    given_the_service_is_open
    and_the_identity_service_is_running
    when_i_visit_the_staff_sign_in_page
    then_i_see_the_option_to_sign_in_using_identity
    when_i_sign_in_with_identity
    then_i_see_the_support_dashboard
    and_i_see_the_success_message
  end

  private

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_the_service_is_staff_http_basic_auth
    FeatureFlag.activate(:staff_http_basic_auth)
  end

  def when_i_am_authorized_as_a_support_user
    page.driver.basic_authorize(
      ENV.fetch("SUPPORT_USERNAME", "test"),
      ENV.fetch("SUPPORT_PASSWORD", "test"),
    )
  end

  def when_i_visit_the_staff_page
    visit support_interface_staff_index_path
  end

  def when_i_visit_the_invitation_email
    message = ActionMailer::Base.deliveries.first
    uri = URI.parse(URI.extract(message.body.to_s).second)
    expect(uri.path).to eq("/staff/invitation/accept")
    expect(uri.query).to include("invitation_token=")
    visit "#{uri.path}?#{uri.query}"
  end

  def when_i_click_on_invite
    click_link "Invite"
  end

  def when_i_fill_email_address
    fill_in "staff-email-field", with: "test@example.com"
  end

  def then_i_see_the_staff_index
    expect(page).to have_current_path("/support/staff")
    expect(page).to have_title("Staff")
  end

  def then_i_see_the_staff_invitation_form
    expect(page).to have_current_path("/staff/invitation/new")
    expect(page).to have_content("Send invitation")
    expect(page).to have_content("Email")
    expect(page).to have_content("Send an invitation")
  end

  def then_i_see_an_invitation_email
    perform_enqueued_jobs
    message = ActionMailer::Base.deliveries.first
    expect(message).to_not be_nil

    expect(message.subject).to eq("Invitation instructions")
    expect(message.to).to include("test@example.com")
  end

  def then_i_see_the_invited_staff_user
    expect(page).to have_content("test@example.com")
    expect(page).to have_content("Not accepted")
  end

  def then_i_see_the_accepted_staff_user
    expect(page).to have_content("test@example.com")
    expect(page).to have_content("Accepted")
  end

  def and_i_fill_password
    fill_in "staff-password-field", with: "password"
    fill_in "staff-password-confirmation-field", with: "password"
  end

  def and_i_send_invitation
    click_button "Send an invitation", visible: false
  end

  def and_i_set_password
    click_button "Set my password", visible: false
  end

  def then_i_see_the_option_to_sign_in_using_identity
    expect(page).to have_button("Sign in with Identity")
  end

  def when_i_visit_the_staff_sign_in_page
    visit new_staff_session_path
  end

  def when_i_sign_in_with_identity
    click_button "Sign in with Identity"
  end

  def and_the_identity_service_is_running
    FeatureFlag.activate(:identity_auth_service)
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(
      :identity,
      {
        uid: nil,
        credentials: {
          token: {
            access_token: "1234567890",
            expires_at: 1.minute.from_now.to_i,
          },
        },
        extra: {
          raw_info: {
            email: "new@example.com",
          },
        },
      },
    )
  end

  def and_i_see_the_success_message
    expect(page).to have_content("Signed in successfully.")
  end

  def then_i_see_the_support_dashboard
    expect(page).to have_current_path("/support/trn-requests")
    expect(page).to have_title("TRN Requests")
  end
end
