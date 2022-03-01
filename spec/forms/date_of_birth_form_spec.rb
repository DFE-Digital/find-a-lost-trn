# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DateOfBirthForm, type: :model do
  it { is_expected.to validate_presence_of(:date_of_birth).with_message('Enter your date of birth') }

  describe '#update' do
    subject(:update) { date_of_birth_form.update(params) }

    let(:date_of_birth_form) { described_class.new(trn_request: trn_request) }
    let(:params) { { 'date_of_birth(1i)' => '2000', 'date_of_birth(2i)' => '01', 'date_of_birth(3i)' => '01' } }
    let(:trn_request) { TrnRequest.new }

    it 'updates the date of birth' do
      update
      expect(date_of_birth_form.date_of_birth).to eq(Date.new(2000, 1, 1))
    end

    context 'without a valid date' do
      let(:params) { { 'date_of_birth(1i)' => '2000', 'date_of_birth(2i)' => '02', 'date_of_birth(3i)' => '30' } }

      it 'does not update the date of birth' do
        update
        expect(date_of_birth_form.date_of_birth).to be_nil
      end
    end

    context 'with a blank date' do
      let(:params) { { 'date_of_birth(1i)' => '', 'date_of_birth(2i)' => '', 'date_of_birth(3i)' => '' } }

      it { is_expected.to be_falsy }

      it 'adds an error' do
        update
        expect(date_of_birth_form.errors[:date_of_birth]).to eq(['Enter your date of birth'])
      end
    end

    context 'when the date is in the future' do
      let(:params) do
        { 'date_of_birth(1i)' => 1.year.from_now.year, 'date_of_birth(2i)' => '01', 'date_of_birth(3i)' => '01' }
      end

      it { is_expected.to be_falsy }

      it 'adds an error' do
        update
        expect(date_of_birth_form.errors[:date_of_birth]).to eq(['You must be 16 or over to use this service'])
      end
    end

    context 'with an invalid date' do
      let(:params) { { 'date_of_birth(1i)' => '', 'date_of_birth(2i)' => '1', 'date_of_birth(3i)' => '1' } }

      it { is_expected.to be_falsy }

      it 'adds an error' do
        update
        expect(date_of_birth_form.errors[:date_of_birth]).to eq(['Enter your date of birth'])
      end
    end

    context 'with a date less than 16 years ago' do
      let(:params) do
        {
          'date_of_birth(1i)' => 15.years.ago.year,
          'date_of_birth(2i)' => Time.zone.today.month,
          'date_of_birth(3i)' => Time.zone.today.day,
        }
      end

      it { is_expected.to be_falsy }

      it 'adds an error' do
        update
        expect(date_of_birth_form.errors[:date_of_birth]).to eq(['You must be 16 or over to use this service'])
      end
    end

    context 'with a date before 1900' do
      let(:params) { { 'date_of_birth(1i)' => '1899', 'date_of_birth(2i)' => '1', 'date_of_birth(3i)' => '1' } }

      it { is_expected.to be_falsy }

      it 'adds an error' do
        update
        expect(date_of_birth_form.errors[:date_of_birth]).to eq(['You must be 16 or over to use this service'])
      end
    end
  end
end
