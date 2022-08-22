class AddTrnFromUserToTrnRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :trn_requests, :trn_from_user, :string
  end
end
