# frozen_string_literal: true
class IdentityController < ApplicationController
  skip_forgery_protection

  include EnforceQuestionOrder

  skip_before_action :redirect_to_next_question

  def create
    unless FeatureFlag.active?(:identity_open)
      raise IdentityEndpointOffError,
            "Could not access the get an identity endpoint because the " \
              ":identity_open feature flag is off"
    end

    unless valid_identity_params?
      raise IdentityDataError,
            "Could not continue because the " \
              "data from Identity was unable to be verified"
    end

    @trn_request =
      TrnRequest.create!(
        email: allowed_create_params["email"],
        from_get_an_identity: true
      )

    session[:trn_request_id] = @trn_request.id
    session[:identity_journey_id] = allowed_create_params["journey_id"]
    session[:identity_redirect_uri] = allowed_create_params["redirect_uri"]
    session[:identity_client_title] = allowed_create_params["client_title"]
    session[:identity_client_url] = allowed_create_params["client_url"]

    redirect_to next_question_path
  end

  private

  def allowed_create_params
    params.permit(
      :client_url,
      :email,
      :redirect_uri,
      :client_title,
      :journey_id,
      :sig
    )
  end

  # Compare the signature provided by Identity with the signature calcuated
  # using the received params. If they match then data has not been tampered with.
  def valid_identity_params?
    return false if expected_signature.blank? || new_signature.blank?

    expected_signature.upcase == new_signature.upcase
  end

  # Retrieve the signature provided by Identity
  def expected_signature
    allowed_create_params.key?("sig") ? allowed_create_params["sig"] : ""
  end

  def new_signature
    Identity.signature_from(allowed_create_params.except("sig"))
  end

  class IdentityEndpointOffError < StandardError
  end

  class IdentityDataError < StandardError
  end
end
