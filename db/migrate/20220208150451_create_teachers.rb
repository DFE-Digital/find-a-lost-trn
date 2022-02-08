# frozen_string_literal: true
class CreateTeachers < ActiveRecord::Migration[7.0]
  def change
    create_table :teachers do |t|
      t.string :identifier
      t.string :last_completed_step
      t.boolean :submitted

      t.string :first_name
      t.string :last_name
      t.string :previous_first_name
      t.string :previous_last_name
      t.string :email
      t.string :ni_number
      t.string :itt_provider
      t.date :date_of_birth

      t.string :trn

      t.timestamps
    end
  end
end
