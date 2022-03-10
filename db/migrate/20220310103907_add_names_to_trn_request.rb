# frozen_string_literal: true
class AddNamesToTrnRequest < ActiveRecord::Migration[7.0]
  def change
    change_table :trn_requests, bulk: true do |t|
      t.string :first_name
      t.string :last_name
      t.string :previous_first_name
      t.string :previous_last_name
      t.remove :name, type: :string
    end
  end
end
