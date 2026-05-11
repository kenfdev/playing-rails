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

ActiveRecord::Schema[8.1].define(version: 2026_05_10_120000) do
  create_table "educations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "degree"
    t.date "end_date"
    t.string "field"
    t.integer "profile_id", null: false
    t.string "school", null: false
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_educations_on_profile_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "headline"
    t.string "name"
    t.datetime "profile_updated_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "salaries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "current_amount"
    t.integer "expected_max"
    t.integer "expected_min"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_salaries_on_user_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "name_normalized", null: false
    t.integer "profile_id", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id", "name_normalized"], name: "index_skills_on_profile_id_and_name_normalized", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "work_histories", force: :cascade do |t|
    t.string "company", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_date"
    t.integer "profile_id", null: false
    t.date "start_date", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_work_histories_on_profile_id"
  end

  add_foreign_key "educations", "profiles"
  add_foreign_key "profiles", "users"
  add_foreign_key "salaries", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "skills", "profiles"
  add_foreign_key "work_histories", "profiles"
end
