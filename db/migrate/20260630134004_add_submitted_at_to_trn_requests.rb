class AddSubmittedAtToTrnRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :trn_requests, :submitted_at, :datetime
  end
end
