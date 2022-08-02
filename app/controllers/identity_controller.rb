class IdentityController < ApplicationController
  def create
    session[:redirect_uri] = params.fetch(:redirect_uri)

    trn_request = TrnRequest.create!(email: params.fetch(:email))
    session[:trn_request_id] = trn_request.id

    redirect_to have_trn_path
  end
end
