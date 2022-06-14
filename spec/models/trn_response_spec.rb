# frozen_string_literal: true
require 'rails_helper'

RSpec.describe TrnResponse, type: :model do
  subject(:trn_response) { described_class.new(trn_request: trn_request) }

  let(:trn_request) { build(:trn_request) }

  it { is_expected.to be_valid }
  it { is_expected.to belong_to(:trn_request) }
end
