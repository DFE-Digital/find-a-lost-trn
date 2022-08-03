class ChangeNameLength < ActiveRecord::Migration[7.0]
  def change
    change_column :trn_requests, :first_name, :string, limit: 510
    change_column :trn_requests, :last_name, :string, limit: 510
    change_column :trn_requests, :previous_first_name, :string, limit: 510
    change_column :trn_requests, :previous_last_name, :string, limit: 510
  end
end
