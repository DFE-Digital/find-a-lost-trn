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

ActiveRecord::Schema[7.0].define(version: 2022_07_11_155924) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "features", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_features_on_name", unique: true
  end

  create_table "trn_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "checked_at", precision: nil
    t.date "date_of_birth"
    t.string "email"
    t.string "ni_number"
    t.boolean "itt_provider_enrolled"
    t.string "itt_provider_name"
    t.boolean "has_ni_number"
    t.string "first_name"
    t.string "last_name"
    t.string "previous_first_name"
    t.string "previous_last_name"
    t.string "trn"
    t.integer "zendesk_ticket_id"
    t.boolean "awarded_qts"
    t.boolean "has_active_sanctions"
  end

  create_table "trn_responses", force: :cascade do |t|
    t.bigint "trn_request_id", null: false
    t.json "raw_result", default: "{}"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trn_request_id"], name: "index_trn_responses_on_trn_request_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "validation_errors", force: :cascade do |t|
    t.string "form_object", null: false
    t.jsonb "messages", default: "{}", null: false
    t.bigint "trn_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["messages"], name: "index_validation_errors_on_messages", using: :gin
    t.index ["trn_request_id"], name: "index_validation_errors_on_trn_request_id"
  end

  add_foreign_key "trn_responses", "trn_requests"
  add_foreign_key "validation_errors", "trn_requests"
end
