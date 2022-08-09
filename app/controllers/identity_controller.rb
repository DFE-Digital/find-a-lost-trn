# frozen_string_literal: true
class IdentityController < ApplicationController
  def create
    unless FeatureFlag.active?(:identity_open)
      raise IdentityEndpointOffError,
            "Could not access the get an identity endpoint because the " \
              ":identity_open feature flag is off"
    end

    head :no_content
  end

  class IdentityEndpointOffError < StandardError
  end
end
