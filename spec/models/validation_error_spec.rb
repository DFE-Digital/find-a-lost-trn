# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ValidationError, type: :model do
  it { is_expected.to belong_to(:trn_request) }
  it { is_expected.to validate_presence_of(:form_object) }
  it { is_expected.to validate_presence_of(:messages) }
end
