class CreateAccountUnlockEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :account_unlock_events do |t|

      t.timestamps
    end
  end
end
