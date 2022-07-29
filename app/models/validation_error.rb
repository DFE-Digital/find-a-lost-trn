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
class ValidationError < ApplicationRecord
  belongs_to :trn_request

  validates :form_object, presence: true
  validates :messages, presence: true
end
