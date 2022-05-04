# frozen_string_literal: true
class AddHasActiveSanctionsToTrnRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :trn_requests, :has_active_sanctions, :boolean
  end
end
