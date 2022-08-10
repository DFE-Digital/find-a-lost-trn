# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Identity", type: :system do
  before do
    given_the_service_is_open
    given_the_identity_endpoint_is_open
  end

  after { deactivate_feature_flags }

  it "verifies the parameters" do
    and_i_access_the_identity_endpoint_with_parameters
    then_i_see_no_content
  end

  it "does not verify with modified parameters" do
    and_i_access_the_identity_endpoint_with_modified_parameters_it_raises_an_error
  end

  private

  def and_i_access_the_identity_endpoint_with_parameters
    params = {
      redirect_uri: "https://authserveruri/",
      client_title: "The Client Title",
      email: "joe.bloggs@example.com",
      journey_id: "9ddccb62-ec13-4ea7-a163-c058a19b8222",
      sig: "E03C7295CF8B3C444C21D8D88B04D4B377615B68A92C83B3321A3F71CF8E4A6D"
    }

    post identity_path, params:
  end

  def and_i_access_the_identity_endpoint_with_modified_parameters_it_raises_an_error
    params = {
      redirect_uri: "https://authserveruri/",
      client_title: "New Title",
      email: "john.smith@example.com",
      journey_id: "9ddccb62-ec13-4ea7-a163-c058a19b8222",
      sig: "E03C7295CF8B3C444C21D8D88B04D4B377615B68A92C83B3321A3F71CF8E4A6D"
    }

    expect { post identity_path, params: }.to raise_error(
      IdentityController::IdentityDataError
    )
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
