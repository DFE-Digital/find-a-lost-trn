# frozen_string_literal: true
require 'rails_helper'

RSpec.describe TrnRequest, type: :model do
  subject(:trn_request) { described_class.new }

  describe '#answers_checked=' do
    before { trn_request.answers_checked = value }

    context 'when true' do
      let(:value) { true }

      it 'stores the current timestamp on checked_at' do
        expect(trn_request.checked_at).to be_present
      end
    end

    context 'when false' do
      let(:value) { false }

      it 'does not set checked_at' do
        expect(trn_request.checked_at).to be_nil
      end
    end
  end

  context 'when the ITT provider enrollment question has been asked' do
    subject(:trn_request) { described_class.create(itt_provider_enrolled: true) }

    context 'when the email is blank' do
      before { trn_request.email = '' }

      it { is_expected.to be_invalid }

      it 'displays a blank email error' do
        trn_request.validate
        expect(trn_request.errors.messages[:email]).to include(
          'Enter an email address in the correct format, like name@example.com',
        )
      end
    end

    context 'when the email is not blank' do
      before { trn_request.email = 'test@example.com' }

      it { is_expected.to be_valid }
    end
  end

  it { is_expected.to validate_length_of(:itt_provider_name).is_at_most(255) }
end
