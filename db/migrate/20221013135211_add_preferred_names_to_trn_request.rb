class AddPreferredNamesToTrnRequest < ActiveRecord::Migration[7.0]
  def change
    change_table :trn_requests, bulk: true do |t|
      t.column :preferred_first_name, :string
      t.column :preferred_last_name, :string
    end
  end
end
