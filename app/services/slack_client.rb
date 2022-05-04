# frozen_string_literal: true
class SlackClient
  class Error < StandardError
  end

  def self.create_message(message)
    new.create_message(message)
  end

  def create_message(message)
    response =
      client.post(
        'chat.postMessage',
        { channel: "##{ENV['SLACK_CHANNEL']}", mrkdwn: true, text: message },
      )
    return if response.success?

    raise Error, "Status code: #{response.status} - #{response.body}"
  end

  private

  def client
    Faraday.new(url: 'https://slack.com/api') do |faraday|
      faraday.authorization :Bearer, ENV['SLACK_TOKEN']
      faraday.request :json
      faraday.response :json
      faraday.response :logger, nil, { bodies: true, headers: true }
      faraday.adapter Faraday.default_adapter
    end
  end
end
