class AddPreferredNamesToTrnRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :trn_requests, :preferred_first_name, :string
    add_column :trn_requests, :preferred_last_name, :string
  end
end
