# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Identity", type: :system do
  before do
    given_the_service_is_open
    given_the_identity_endpoint_is_open
  end

  after { deactivate_feature_flags }

  it "using the identity endpoint returns no content" do
    and_i_access_the_identity_endpoint
    then_i_see_no_content
  end

  private

  def and_i_access_the_identity_endpoint
    post identity_path
  end

  def then_i_see_no_content
    expect(response).to have_http_status(:no_content)
  end

  def deactivate_feature_flags
    FeatureFlag.deactivate(:service_open)
    FeatureFlag.deactivate(:identity_open)
  end

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_the_identity_endpoint_is_open
    FeatureFlag.activate(:identity_open)
  end
end
