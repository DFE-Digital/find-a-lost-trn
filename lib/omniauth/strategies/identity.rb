module Omniauth
  module Strategies
    class Identity < OmniAuth::Strategies::OAuth2
      option :name, :identity

      option :client_options,
             {
               authorize_url: "/connect/authorize",
               site: ENV["IDENTITY_API_URL"],
               token_url: "/connect/token",
             }
      option :pkce, true
      option :scope, "get-an-identity:support"

      info { { name: raw_info["name"], email: raw_info["email"] } }

      extra { { "raw_info" => raw_info } }

      def raw_info
        @raw_info ||= access_token.get("connect/userinfo").parsed
      end

      def build_access_token
        verifier = request.params["code"]
        redirect_uri = full_host + callback_path
        client.auth_code.get_token(
          verifier,
          { redirect_uri: }.merge(token_params.to_hash(symbolize_keys: true)),
          deep_symbolize(options.auth_token_params),
        )
      end
    end
  end
end
