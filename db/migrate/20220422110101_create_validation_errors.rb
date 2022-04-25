# frozen_string_literal: true
class CreateValidationErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :validation_errors do |t|
      t.string :form_object, null: false
      t.jsonb :messages, default: '{}', null: false
      t.references :trn_request, null: false, foreign_key: true

      t.timestamps
    end

    add_index :validation_errors, :messages, using: :gin
  end
end
