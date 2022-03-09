# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IttProviderForm, type: :model do
  describe 'validations' do
    specify do
      form = described_class.new
      expect(form).to validate_presence_of(:itt_provider_enrolled).with_message(
        'Tell us if you’ve been enrolled in initial teacher training',
      )
    end

    specify do
      form = described_class.new(itt_provider_enrolled: 'true')
      expect(form).to validate_presence_of(:itt_provider_name).with_message(
        'Enter your school, university or other training provider',
      )
    end

    specify do
      form = described_class.new(itt_provider_enrolled: 'true')
      expect(form).to validate_length_of(:itt_provider_name)
        .is_at_most(255)
        .with_message('Enter a school that is less than 255 letters long')
    end
  end

  describe '#save' do
    context 'when itt_provider_enrolled is missing' do
      it 'returns false' do
        form = described_class.new

        expect(form.save).to be false
      end
    end

    context 'when form data is correct' do
      it 'saves the model' do
        form =
          described_class.new(
            trn_request: TrnRequest.new,
            itt_provider_enrolled: 'true',
            itt_provider_name: 'Big SCITT',
          )

        form.save

        expect(form.trn_request.itt_provider_enrolled).to be true
        expect(form.trn_request.itt_provider_name).to eq 'Big SCITT'
      end
    end
  end
end
