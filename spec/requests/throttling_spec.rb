# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Throttling', rack_attack: true do
  before { FeatureFlag.activate(:service_open) }

  shared_examples 'throttled' do |path|
    context path do
      subject(:cache_count) { Rack::Attack.cache.count('requests by IP address:127.0.0.1', 1.minute) }

      before { get path }

      it { is_expected.to eq(2) }
    end
  end

  %w[
    /name
    /date-of-birth
    /have-ni-number
    /ni-number
    /awarded-qts
    /itt-provider
    /email
    /check-answers
    /check-trn
    /support
  ].each { |path| include_examples 'throttled', path }
end
