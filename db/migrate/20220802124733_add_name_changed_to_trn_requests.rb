class AddNameChangedToTrnRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :trn_requests, :name_changed, :boolean
  end
end
