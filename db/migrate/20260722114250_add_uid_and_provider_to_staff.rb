class AddUidAndProviderToStaff < ActiveRecord::Migration[7.2]
  def change
    change_table :staff, bulk: true do |t|
      t.string :uid
      t.string :provider
    end
    add_index :staff, %i[provider uid], unique: true
  end
end
