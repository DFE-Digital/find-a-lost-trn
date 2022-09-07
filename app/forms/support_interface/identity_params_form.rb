module SupportInterface
  class IdentityParamsForm
    include ActiveModel::Model

    attr_accessor :client_title, :email, :journey_id, :redirect_uri, :client_url
  end
end
