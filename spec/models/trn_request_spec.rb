# frozen_string_literal: true
require 'rails_helper'

RSpec.describe TrnRequest, type: :model do
  subject(:trn_request) do
    described_class.new(email: 'test@example.com', has_ni_number: false, itt_provider_enrolled: 'no')
  end

  it { is_expected.to be_valid }

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

  context 'when the ITT provider enrollment and NI number questions have been asked' do
    subject(:trn_request) { described_class.create(has_ni_number: false, itt_provider_enrolled: true) }

    it 'validates the presence of the email address' do
      expect(trn_request).to validate_presence_of(:email).with_message(
        'Enter an email address in the correct format, like name@example.com',
      )
    end
  end

  describe '#name' do
    subject { trn_request.name }

    let(:trn_request) { described_class.new(first_name: 'John', last_name: 'Doe') }

    it { is_expected.to eq('John Doe') }
  end

  describe '#previous_name?' do
    subject { trn_request.previous_name? }

    context 'when a previous first name is present' do
      let(:trn_request) { described_class.new(previous_first_name: 'John') }

      it { is_expected.to be_truthy }
    end

    context 'when a previous last name is present' do
      let(:trn_request) { described_class.new(previous_last_name: 'John') }

      it { is_expected.to be_truthy }
    end
  end

  describe '#previous_name' do
    subject { trn_request.previous_name }

    context 'when a previous first name is present' do
      let(:trn_request) { described_class.new(first_name: 'John', last_name: 'Doe', previous_first_name: 'Joan') }

      it { is_expected.to eq('Joan Doe') }
    end

    context 'when a previous last name is present' do
      let(:trn_request) { described_class.new(first_name: 'John', last_name: 'Doe', previous_last_name: 'Smith') }

      it { is_expected.to eq('John Smith') }
    end
  end
end
