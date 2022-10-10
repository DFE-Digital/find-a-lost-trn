# frozen_string_literal: true
module SupportInterface
  class SupportInterfaceController < ApplicationController
    layout "support_layout"

    before_action :authenticate_staff!,
                  unless: -> { FeatureFlag.active?(:identity_auth_service) }
    before_action :check_omniauth_token!,
                  if: -> { FeatureFlag.active?(:identity_auth_service) }

    def find_current_auditor
      current_staff
    end

    def check_omniauth_token!
      redirect_to new_staff_session_path unless valid_access_token?
    end

    def valid_access_token?
      credentials = session[:identity_users_api_access_token]
      credentials.present? &&
        Time.zone.at(credentials.fetch("expires_at", 0)).future?
    end
  end
end
