# frozen_string_literal: true
class AddDetailsToTrnRequest < ActiveRecord::Migration[7.0]
  def change
    change_table :trn_requests, bulk: true do |t|
      t.datetime :checked_at
      t.date :date_of_birth
      t.string :email
      t.string :name
      t.string :ni_number
    end
  end
end
