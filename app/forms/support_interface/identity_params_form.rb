module SupportInterface
  class IdentityParamsForm
    include ActiveModel::Model

    attr_accessor :client_title,
                  :client_id,
                  :email,
                  :journey_id,
                  :redirect_url,
                  :client_url,
                  :previous_url
  end
end
