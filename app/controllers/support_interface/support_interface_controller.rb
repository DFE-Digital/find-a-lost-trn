# frozen_string_literal: true
module SupportInterface
  class SupportInterfaceController < ApplicationController
    layout "support_layout"

    before_action :authenticate_staff!
  end
end
