class KnowTrnController < ApplicationController
  layout "two_thirds"

  def new
    @know_trn_form = KnowTrnForm.new(trn_request:)
  end

  def create
    @know_trn_form = KnowTrnForm.new(know_trn_params.merge(trn_request:))
    if @know_trn_form.save
      payload = { trn: @trn_request.trn }
      key = Base64.decode64 ENV.fetch("IDENTITY_JWT_KEY")
      token = JWT.encode payload, key, "HS256"
      redirect_to "#{session[:redirect_uri]}&user=#{token}",
                  allow_other_host: true
    else
      render :new
    end
  end

  private

  def trn_request
    @trn_request ||=
      TrnRequest.find_or_initialize_by(id: session[:trn_request_id])
  end

  def know_trn_params
    params.require(:know_trn_form).permit(:know_trn, :trn)
  end
end
