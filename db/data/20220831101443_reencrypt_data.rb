# frozen_string_literal: true

class ReencryptData < ActiveRecord::Migration[7.0]
  def up
    TrnRequest.find_each do |trn_request|
      trn_request.decrypt
      trn_request.encrypt
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
