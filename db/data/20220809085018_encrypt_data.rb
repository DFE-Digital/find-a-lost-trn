# frozen_string_literal: true

class EncryptData < ActiveRecord::Migration[7.0]
  def up
    TrnRequest.find_each(&:encrypt)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
