# frozen_string_literal: true
require "rails_helper"

RSpec.describe CheckTrnForm, type: :model do
  it { is_expected.to validate_inclusion_of(:has_trn).in_array(%w[true false]) }

  describe "#valid?" do
    subject(:valid) { check_trn_form.valid? }

    let(:check_trn_form) { described_class.new(has_trn:) }
    let(:has_trn) { "true" }

    it { is_expected.to be_truthy }

    context "when the has_trn is blank" do
      let(:has_trn) { "" }

      it { is_expected.to be_falsy }

      it "logs a validation error" do
        FeatureFlag.activate(:log_validation_errors)
        expect { valid }.to change(ValidationError, :count).by(1)
      end
    end
  end
end
