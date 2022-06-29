# frozen_string_literal: true
module SupportInterface
  class SupportInterfaceController < ApplicationController
    layout "support_layout"

    http_basic_authenticate_with name: ENV.fetch("SUPPORT_USERNAME", nil),
                                 password: ENV.fetch("SUPPORT_PASSWORD", nil)
  end
end
