# frozen_string_literal: true
class AddNiNumberToTrnRequest < ActiveRecord::Migration[7.0]
  def change
    change_table :trn_requests, bulk: true do |t|
      t.boolean :has_ni_number
    end
  end
end
