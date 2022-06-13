# frozen_string_literal: true
class CreateTrnResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :trn_responses do |t|
      t.belongs_to :trn_request, null: false, foreign_key: true
      t.json :raw_result, default: '{}'

      t.timestamps
    end
  end
end
