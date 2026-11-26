require "base64"

module System
  module BasicAuthHelpers
    # Sends the credentials as a header on every request, rather than through
    # Cuprite's basic_authorize, which answers the browser's auth challenge by
    # intercepting each request. From Ferrum 0.15 that interception can leave
    # a page's assets paused until the visit times out. The header goes
    # through Ferrum because Cuprite 0.21 removes the driver's headers=.
    #
    # Base64 rather than a Rails class, because the smoke spec loads only
    # spec_helper.
    def basic_authorize(username, password)
      credentials = Base64.strict_encode64("#{username}:#{password}")
      page.driver.browser.headers.set("Authorization" => "Basic #{credentials}")
    end
  end
end

RSpec.configure do |config|
  config.include System::BasicAuthHelpers, type: :system
end
