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

  describe '#update' do
    subject(:update) { has_ni_number_form.update(params) }

    context 'when the form is invalid' do
      let(:params) { { trn_request: TrnRequest.new } }

      it { is_expected.to be_falsy }

      it 'logs a validation error' do
        FeatureFlag.activate(:log_validation_errors)
        expect { update }.to change(ValidationError, :count).by(1)
      end
    end
  end
end
