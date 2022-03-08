# frozen_string_literal: true
require 'rails_helper'

RSpec.describe HasNiNumberForm, type: :model do
  subject(:has_ni_number_form) { described_class.new(trn_request: trn_request) }

  let(:trn_request) { TrnRequest.new }

  specify do
    expect(has_ni_number_form).to validate_presence_of(:has_ni_number).with_message(
      'Tell us if you have a National Insurance number',
    )
  end
end
