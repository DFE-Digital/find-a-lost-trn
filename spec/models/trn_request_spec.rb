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

  describe '#status' do
    subject { trn_request.status }

    let(:trn_request) { described_class.new(attributes) }

    context 'when no attributes are present' do
      let(:attributes) { nil }

      it { is_expected.to eq(:name) }
    end

    context 'when a name is present' do
      let(:attributes) { { first_name: 'John', last_name: 'Smith' } }

      it { is_expected.to eq(:date_of_birth) }
    end

    context 'when a date of birth is present' do
      let(:attributes) { { date_of_birth: '01/01/2000', first_name: 'John', last_name: 'Smith' } }

      it { is_expected.to eq(:has_ni_number) }
    end

    context 'when has_ni_number is true' do
      let(:attributes) { { date_of_birth: '01/01/2000', first_name: 'John', has_ni_number: true, last_name: 'Smith' } }

      it { is_expected.to eq(:ni_number) }
    end

    context 'when an NI number is present' do
      let(:attributes) { { date_of_birth: '01/01/2000', has_ni_number: false, first_name: 'John', last_name: 'Smith' } }

      it { is_expected.to eq(:awarded_qts) }
    end

    context 'when awarded QTS is present' do
      let(:attributes) { { awarded_qts: true, date_of_birth: '01/01/2000', first_name: 'John', last_name: 'Smith' } }

      it { is_expected.to eq(:itt_provider) }
    end

    context 'when awarded QTS is false' do
      let(:attributes) do
        {
          awarded_qts: false,
          date_of_birth: '01/01/2000',
          first_name: 'John',
          has_ni_number: false,
          last_name: 'Smith',
        }
      end

      it { is_expected.to eq(:email) }
    end

    context 'when an ITT provider is present' do
      let(:attributes) do
        {
          awarded_qts: true,
          date_of_birth: '01/01/2000',
          first_name: 'John',
          itt_provider_enrolled: false,
          last_name: 'Smith',
          has_ni_number: false,
        }
      end

      it { is_expected.to eq(:email) }
    end

    context 'when an email is present' do
      let(:attributes) do
        {
          date_of_birth: '01/01/2000',
          email: 'test@example.com',
          first_name: 'John',
          itt_provider_enrolled: 'yes',
          itt_provider_name: 'Example',
          last_name: 'Smith',
          ni_number: 'QQ123456C',
        }
      end

      it { is_expected.to eq(:answers) }
    end
  end
end
