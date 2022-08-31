# frozen_string_literal: true

class EncryptAllWithEmail < ActiveRecord::Migration[7.0]
  def up
    TrnRequest.find_each(&:encrypt)
  end

  def down
    TrnRequest.find_each(&:decrypt)
  end
end
