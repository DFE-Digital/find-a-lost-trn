require 'faraday'
require 'faraday/net_http'
Faraday.default_adapter = :net_http

class DqtApi
  def initialize
    @conn = Faraday.new(
      url: ENV['DQT_API_BASE_URL'],
      headers: { 'Authorization' => "Bearer #{ENV['DQT_API_TOKEN']}"}
    )
  end

  def find_trn(
    date_of_birth:,
    email_address:,
    first_name:,
    last_name:,
    ni_number:,
    itt_provider_name:
  )
    params = {
      dateOfBirth: date_of_birth,
      emailAddress: email_address,
      firstName: first_name,
      lastName: last_name,
      nationalInsuranceNumber: ni_number,
      ittProviderName: itt_provider_name,
    }
    result = @conn.get('/v2/teachers/find', params)

    JSON.parse(result.body)
  end
end
