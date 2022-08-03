class ChangeNameLength < ActiveRecord::Migration[7.0]
  def up
    change_table :trn_requests, bulk: true do |t|
      t.change :first_name, :string, limit: 510
      t.change :last_name, :string, limit: 510
      t.change :previous_first_name, :string, limit: 510
      t.change :previous_last_name, :string, limit: 510
    end
  end

  def down
    change_table :trn_requests, bulk: true do |t|
      t.change :first_name, :string, limit: 255
      t.change :last_name, :string, limit: 255
      t.change :previous_first_name, :string, limit: 255
      t.change :previous_last_name, :string, limit: 255
    end
  end
end
