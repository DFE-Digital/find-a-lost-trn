class AccountUnlockEvent < ApplicationRecord
  belongs_to :trn_request
end
