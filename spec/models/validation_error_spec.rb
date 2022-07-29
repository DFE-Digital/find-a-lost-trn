# frozen_string_literal: true

# == Schema Information
#
# Table name: validation_errors
#
#  id             :bigint           not null, primary key
#  form_object    :string           not null
#  messages       :jsonb            not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  trn_request_id :bigint           not null
#
# Indexes
#
#  index_validation_errors_on_messages        (messages) USING gin
#  index_validation_errors_on_trn_request_id  (trn_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (trn_request_id => trn_requests.id)
#
require "rails_helper"

RSpec.describe ValidationError, type: :model do
  it { is_expected.to belong_to(:trn_request) }
  it { is_expected.to validate_presence_of(:form_object) }
  it { is_expected.to validate_presence_of(:messages) }
end
