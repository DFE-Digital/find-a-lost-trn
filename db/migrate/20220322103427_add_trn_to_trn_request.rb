# frozen_string_literal: true
class AddTrnToTrnRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :trn_requests, :trn, :string
  end
end
