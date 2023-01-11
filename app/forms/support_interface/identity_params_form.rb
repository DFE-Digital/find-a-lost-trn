module SupportInterface
  class IdentityParamsForm
    include ActiveModel::Model

    attr_accessor :client_id,
                  :client_title,
                  :client_url,
                  :email,
                  :journey_id,
                  :previous_url,
                  :redirect_url,
                  :session_id
  end
end
