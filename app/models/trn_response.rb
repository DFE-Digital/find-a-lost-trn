# frozen_string_literal: true

# == Schema Information
#
# Table name: trn_responses
#
#  id             :bigint           not null, primary key
#  raw_result     :json
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  trn_request_id :bigint           not null
#
# Indexes
#
#  index_trn_responses_on_trn_request_id  (trn_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (trn_request_id => trn_requests.id)
#
class TrnResponse < ApplicationRecord
  belongs_to :trn_request
end
