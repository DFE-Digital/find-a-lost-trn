module SupportInterface
  class IdentityParamsForm
    include ActiveModel::Model

    attr_accessor :client_title,
                  :email,
                  :journey_id,
                  :redirect_url,
                  :client_url,
                  :previous_url
  end
end
