class CreateAccountUnlockEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :account_unlock_events, &:timestamps
  end
end
