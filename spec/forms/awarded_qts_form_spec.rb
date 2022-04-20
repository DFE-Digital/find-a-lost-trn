# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AwardedQtsForm, type: :model do
  subject(:awarded_qts_form) { described_class.new(trn_request: trn_request) }

  let(:trn_request) { TrnRequest.new }

  specify do
    expect(awarded_qts_form).to validate_presence_of(:awarded_qts).with_message(
      'Tell us if you have been awarded qualified teacher status (QTS)',
    )
  end

  describe '#update' do
    subject(:update) { awarded_qts_form.update(awarded_qts: awarded_qts) }

    let(:awarded_qts) { true }

    it 'updates the awarded_qts attribute on the trn_request' do
      expect { update }.to change(trn_request, :awarded_qts).from(nil).to(true)
    end

    context 'when there are previous ITT provider details and awarded_qts is false' do
      let(:awarded_qts) { false }
      let(:trn_request) { TrnRequest.new(itt_provider_enrolled: true, itt_provider_name: 'Some ITT provider') }

      it 'clears the previous ITT provider details' do
        update
        expect(trn_request.itt_provider_enrolled).to be_nil
        expect(trn_request.itt_provider_name).to be_nil
      end
    end
  end
end
