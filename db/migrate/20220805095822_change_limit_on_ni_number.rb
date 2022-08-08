class ChangeLimitOnNiNumber < ActiveRecord::Migration[7.0]
  def up
    change_table :trn_requests, bulk: true do |t|
      t.change :email, :string, limit: 510
      t.change :ni_number, :string, limit: 510
    end
  end

  def down
    change_table :trn_requests, bulk: true do |t|
      t.change :email, :string, limit: 255
      t.change :ni_number, :string, limit: 255
    end
  end
end
