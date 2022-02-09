# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_02_08_150451) do
  create_table 'teachers', force: :cascade do |t|
    t.string 'identifier'
    t.string 'last_completed_step'
    t.boolean 'submitted'
    t.string 'first_name'
    t.string 'last_name'
    t.string 'previous_first_name'
    t.string 'previous_last_name'
    t.string 'email'
    t.string 'ni_number'
    t.string 'itt_provider'
    t.date 'date_of_birth'
    t.string 'trn'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end
end
