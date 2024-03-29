# frozen_string_literal: true

module ApplicationHelper
  include DfE::Autocomplete::ApplicationHelper

  def back_link_url(back = url_for(:back))
    if session[:form_complete] &&
         [check_answers_path, itt_provider_path].exclude?(request.path)
      return check_answers_path
    end

    back
  end

  def pretty_ni_number(ni_number)
    ni_number.scan(/..?/).join(" ").upcase
  end

  def current_namespace
    section = request.path.split("/").second
    section == "support" ? "support_interface" : "find_interface"
  end

  # S-oftly hy-phenated email
  # john     .doe     @digital     .education     .gov     .uk ->
  # john&shy;.doe&shy;@digital&shy;.education&shy;.gov&shy;.uk
  #
  # We're using `sanitize`, so `html_safe` should be okay here.
  def shy_email(email)
    sanitize(email).scan(/\W?\w+/).join("&shy;").html_safe
  end

  def custom_title(page_title)
    [page_title, service_name].compact.join(" - ")
  end

  def custom_header
    govuk_header(
      homepage_url: t("govuk.url"),
      service_name:,
      service_url: start_path,
    ) do |header|
      case try(:current_namespace)
      when "support_interface"
        header.with_navigation_item(
          active: current_page?(support_interface_trn_requests_path),
          href: support_interface_trn_requests_path,
          text: "TRNs",
        )
        header.with_navigation_item(
          active: current_page?(support_interface_features_path),
          href: support_interface_features_path,
          text: "Features",
        )
        header.with_navigation_item(
          active:
            request.path.start_with?("/support/identity") ||
              request.path.start_with?("/support/dqt_record"),
          href: support_interface_identity_user_index_path,
          text: "Identity",
        )
        header.with_navigation_item(
          active: request.path.start_with?("/support/staff"),
          href: support_interface_staff_index_path,
          text: "Staff",
        )
        header.with_navigation_item(
          active: false,
          href: support_interface_sidekiq_web_path,
          text: "Sidekiq",
        )
        header.with_navigation_item(
          active: current_page?(support_interface_validation_errors_path),
          href: support_interface_validation_errors_path,
          text: "Validations",
        )
        header.with_navigation_item(
          active: request.path.start_with?("/support/zendesk"),
          href: support_interface_zendesk_path,
          text: "Zendesk",
        )
        if current_staff
          header.with_navigation_item(href: staff_sign_out_path, text: "Sign out")
        else
          header.with_navigation_item(href: new_staff_session_path, text: "Sign in")
        end
      end
    end
  end

  def service_name
    if session[:identity_client_title]
      sanitize(session[:identity_client_title])
    else
      t("service.name")
    end
  end

  def is_identity_journey?
    !!session[:identity_journey_id]
  end
end
