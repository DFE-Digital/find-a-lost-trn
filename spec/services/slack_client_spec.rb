# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SlackClient, type: :service do
  describe '#create_message' do
    subject(:create_message) { described_class.create_message(message) }

    let(:faraday) do
      instance_double(
        Faraday::Connection,
        post: instance_double(Faraday::Response, body: {}, status: 200, success?: true),
      )
    end
    let(:message) { 'Example message' }

    before { allow(Faraday).to receive(:new).and_return(faraday) }

    it 'posts a message to the Slack API' do
      create_message
      expect(faraday).to have_received(:post).with('', { text: message })
    end

    context 'when the API returns an error' do
      let(:faraday) do
        instance_double(
          Faraday::Connection,
          post:
            instance_double(Faraday::Response, body: { errors: ['There was an error'] }, status: 500, success?: false),
        )
      end

      it 'raises an exception' do
        expect { create_message }.to raise_error(
          SlackClient::Error,
          'Status code: 500 - {:errors=>["There was an error"]}',
        )
      end
    end
  end
end
