# frozen_string_literal: true
require "dfe/analytics/filtered_request_event"

class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests
  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  http_basic_authenticate_with name: ENV.fetch("SUPPORT_USERNAME", nil),
                               password: ENV.fetch("SUPPORT_PASSWORD", nil),
                               unless: -> {
                                 FeatureFlag.active?("service_open")
                               }

  private

  # Overrides the gem's version so the query string and referer go through
  # Rails' parameter filters before they leave the app
  def trigger_request_event(event_type)
    return unless DfE::Analytics.enabled?
    return if path_excluded?

    request_event =
      DfE::Analytics::FilteredRequestEvent
        .new
        .with_type(event_type)
        .with_request_details(request)
        .with_response_details(response)
        .with_request_uuid(RequestLocals[:dfe_analytics_request_id])
        .with_data(session_id: session[:session_id])
        .with_user(signed_in_staff)

    DfE::Analytics::SendEvents.do([request_event.as_json])
  end

  # current_staff would run the HTTP basic strategy, whose anonymous support
  # user has no ID, so this only reads a staff user who has already signed in
  def signed_in_staff
    staff = warden.user(:staff)
    staff if staff.is_a?(Staff)
  end
end
