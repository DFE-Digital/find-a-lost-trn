class AddFromGetAnIdentityToTrnRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :trn_requests, :from_get_an_identity, :boolean, default: false
  end
end
