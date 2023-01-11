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
        email: recognised_params["email"],
        from_get_an_identity: true,
      )

    reset_session

    session[:trn_request_id] = @trn_request.id
    session[:identity_client_title] = recognised_params["client_title"]
    session[:identity_client_id] = recognised_params["client_id"]
    session[:identity_client_url] = [
      recognised_params["client_url"],
      "session_id=#{recognised_params["session_id"]}",
    ].join("?")
    session[:identity_journey_id] = recognised_params["journey_id"]
    session[:identity_previous_url] = recognised_params["previous_url"]
    session[:identity_redirect_url] = [
      recognised_params["redirect_url"],
      "session_id=#{recognised_params["session_id"]}",
    ].join("?")
    session[:identity_api_request_sent] = false

    redirect_to next_question_path
  end

  private

  def recognised_params
    params.permit(
      :client_title,
      :client_id,
      :client_url,
      :email,
      :journey_id,
      :previous_url,
      :redirect_url,
      :session_id,
      :sig,
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
    params.fetch("sig", "")
  end

  def new_signature
    # Pass in all params without allowlisting via `.permit` to compute the
    # signature. This is necessary because new parameters can be added to Get
    # an Identity, which would cause the sig to change and break us as a
    # downstream user.
    unsafe_params =
      params.to_unsafe_h.except(
        "action",
        "authenticity_token",
        "controller",
        "sig",
      )
    Identity.signature_from(unsafe_params)
  end

  class IdentityEndpointOffError < StandardError
  end

  class IdentityDataError < StandardError
  end
end
