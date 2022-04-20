# frozen_string_literal: true
class AddAwardedQtsToTrnRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :trn_requests, :awarded_qts, :boolean
  end
end
