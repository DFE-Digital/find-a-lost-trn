# == Schema Information
#
# Table name: account_unlock_events
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  trn_request_id :bigint
#
# Indexes
#
#  index_account_unlock_events_on_trn_request_id  (trn_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (trn_request_id => trn_requests.id)
#
class AccountUnlockEvent < ApplicationRecord
  belongs_to :trn_request
end
