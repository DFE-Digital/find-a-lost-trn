# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CheckTrnForm, type: :model do
  it { is_expected.to validate_inclusion_of(:has_trn).in_array(%w[true false]) }
end
