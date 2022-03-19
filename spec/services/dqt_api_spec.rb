# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DqtApi do
  describe '.find_trn!', vcr: true do
    subject(:find_trn!) { described_class.find_trn!(trn_request) }

    let(:trn_request) do
      TrnRequest.new(date_of_birth: '1990-01-01', email: 'kevin@kevin.com', first_name: 'kevin', ni_number: '1000000')
    end

    it { is_expected.to match(hash_including('trn' => '1275362')) }
    it { is_expected.to match(hash_including('emailAddresses' => ['anonymous@anonymousdomain.org.net.co.uk'])) }
    it { is_expected.to match(hash_including('firstName' => 'Kevin')) }
    it { is_expected.to match(hash_including('lastName' => 'Evans')) }
    it { is_expected.to match(hash_including('dateOfBirth' => '1990-01-01')) }
    it { is_expected.to match(hash_including('nationalInsuranceNumber' => 'SD78771P9')) }
    it { is_expected.to match(hash_including('uid' => 'f7891223-7661-e411-8047-005056822391')) }

    context 'when the API returns a timeout error' do
      before { FeatureFlag.activate(:dqt_api_always_timeout) }

      after { FeatureFlag.deactivate(:dqt_api_always_timeout) }

      it 'raises a timeout error' do
        expect { find_trn! }.to raise_error(Faraday::TimeoutError)
      end
    end

    context 'when the API returns more than 1 result' do
      before { FeatureFlag.activate(:dqt_api_too_many_results) }

      after { FeatureFlag.deactivate(:dqt_api_too_many_results) }

      it 'raises a TooManyResults error' do
        expect { find_trn! }.to raise_error(described_class::TooManyResults)
      end
    end
  end
end
