# frozen_string_literal: true
require 'openapi_client'

class DqtApi
  def initialize(host:, access_token:)
    OpenapiClient.configure do |config|
      config.host = host
      config.access_token = access_token
    end

    @instance = OpenapiClient::TeachersApi.new
  end

  def find_trn(first_name:, last_name:)
    opts = { first_name: first_name, last_name: last_name }
    result = @instance.v2_teachers_find_get(opts)
  end
end
