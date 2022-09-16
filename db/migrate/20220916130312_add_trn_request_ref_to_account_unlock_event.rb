class AddTrnRequestRefToAccountUnlockEvent < ActiveRecord::Migration[7.0]
  def change
    add_reference :account_unlock_events, :trn_request, foreign_key: true
  end
end
