# frozen_string_literal: true
class AddIttProviderToTrnRequest < ActiveRecord::Migration[7.0]
  def change
    change_table :trn_requests, bulk: true do |t|
      t.boolean :itt_provider_enrolled
      t.string :itt_provider_name
    end
  end
end
