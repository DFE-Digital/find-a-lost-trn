# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  http_basic_authenticate_with name: ENV['SUPPORT_USERNAME'],
                               password: ENV['SUPPORT_PASSWORD'],
                               unless: -> { FeatureFlag.active?('service_open') }
end
