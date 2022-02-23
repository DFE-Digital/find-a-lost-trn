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

ActiveRecord::Schema[7.0].define(version: 2022_02_23_110719) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'trn_requests', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'checked_at', precision: nil
    t.date 'date_of_birth'
    t.string 'email'
    t.string 'name'
    t.string 'ni_number'
    t.boolean 'itt_provider_enrolled'
    t.string 'itt_provider_name'
    t.boolean 'has_ni_number'
  end
end
