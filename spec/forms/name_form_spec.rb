# frozen_string_literal: true
require 'rails_helper'

RSpec.describe NameForm, type: :model do
  it { is_expected.to validate_presence_of(:first_name).with_message('Enter your first name') }
  it { is_expected.to validate_presence_of(:last_name).with_message('Enter your last name') }
  it { is_expected.to validate_length_of(:first_name).is_at_most(255) }
  it { is_expected.to validate_length_of(:last_name).is_at_most(255) }
  it { is_expected.to validate_length_of(:previous_first_name).is_at_most(255) }
  it { is_expected.to validate_length_of(:previous_last_name).is_at_most(255) }

  context 'when name_changed is true and previous names are empty' do
    subject { described_class.new(name_changed: true) }

    it { is_expected.to validate_absence_of(:name_changed).with_message('Enter a previous first name or last name') }
  end

  describe '#save' do
    subject(:save) { name_form.save }

    let(:last_name) { nil }
    let(:name_form) { described_class.new(first_name: first_name, last_name: last_name, trn_request: trn_request) }
    let(:trn_request) { TrnRequest.new }

    context 'when first and last names are present' do
      let(:first_name) { 'John' }
      let(:last_name) { 'Doe' }

      it { is_expected.to be_truthy }

      it 'sets the first name on the TrnRequest' do
        save
        expect(trn_request.first_name).to eq('John')
      end

      it 'sets the last name on the TrnRequest' do
        save
        expect(trn_request.last_name).to eq('Doe')
      end
    end

    context 'when the previous names are present' do
      let(:name_form) do
        described_class.new(
          first_name: 'John',
          last_name: 'Doe',
          name_changed: true,
          previous_first_name: 'Jonathan',
          previous_last_name: 'Smith',
          trn_request: trn_request,
        )
      end

      it 'sets the previous first name on the TrnRequest' do
        save
        expect(trn_request.previous_first_name).to eq('Jonathan')
      end

      it 'sets the previous last name on the TrnRequest' do
        save
        expect(trn_request.previous_last_name).to eq('Smith')
      end
    end

    context 'when the previous names are present but name_changed is unchecked' do
      let(:name_form) do
        described_class.new(
          first_name: 'John',
          last_name: 'Doe',
          name_changed: false,
          previous_first_name: 'Jonathan',
          previous_last_name: 'Smith',
          trn_request: trn_request,
        )
      end

      it 'clears the previous first name on the TrnRequest' do
        save
        expect(trn_request.previous_first_name).to be_blank
      end

      it 'clears the previous last name on the TrnRequest' do
        save
        expect(trn_request.previous_last_name).to be_blank
      end
    end

    context 'when the form is invalid' do
      let(:first_name) { nil }

      it { is_expected.to be_falsy }

      it 'adds an error' do
        save
        expect(name_form.errors[:first_name]).to include('Enter your first name')
      end
    end
  end

  describe '#first_name' do
    subject { name_form.first_name }

    let(:name_form) { described_class.new(trn_request: trn_request) }
    let(:trn_request) { TrnRequest.new(first_name: 'Existing') }

    it { is_expected.to eq('Existing') }

    context 'when intialized with a first name' do
      let(:name_form) { described_class.new(first_name: 'New', trn_request: trn_request) }

      it { is_expected.to eq('New') }
    end
  end

  describe '#last_name' do
    subject { name_form.last_name }

    let(:name_form) { described_class.new(trn_request: trn_request) }
    let(:trn_request) { TrnRequest.new(last_name: 'Existing') }

    it { is_expected.to eq('Existing') }

    context 'when intialized with a last name' do
      let(:name_form) { described_class.new(last_name: 'New', trn_request: trn_request) }

      it { is_expected.to eq('New') }
    end
  end

  describe '#previous_first_name' do
    subject { name_form.previous_first_name }

    let(:name_form) { described_class.new(trn_request: trn_request) }
    let(:trn_request) { TrnRequest.new(previous_first_name: 'Existing') }

    it { is_expected.to eq('Existing') }

    context 'when intialized with a previous first name' do
      let(:name_form) { described_class.new(name_changed: true, previous_first_name: 'New', trn_request: trn_request) }

      it { is_expected.to eq('New') }
    end
  end

  describe '#previous_last_name' do
    subject { name_form.previous_last_name }

    let(:name_form) { described_class.new(trn_request: trn_request) }
    let(:trn_request) { TrnRequest.new(previous_last_name: 'Existing') }

    it { is_expected.to eq('Existing') }

    context 'when intialized with a previous last name' do
      let(:name_form) { described_class.new(name_changed: true, previous_last_name: 'New', trn_request: trn_request) }

      it { is_expected.to eq('New') }
    end
  end
end
