class AddOfficialNamePreferredToTrnRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :trn_requests, :official_name_preferred, :boolean
  end
end
