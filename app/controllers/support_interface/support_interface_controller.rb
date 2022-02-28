# frozen_string_literal: true
module SupportInterface
  class SupportInterfaceController < ApplicationController
    layout 'support_layout'

    http_basic_authenticate_with name: ENV['SUPPORT_USERNAME'], password: ENV['SUPPORT_PASSWORD']
  end
end
