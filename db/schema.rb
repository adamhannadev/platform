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

ActiveRecord::Schema[7.2].define(version: 2025_07_22_035806) do
  create_table "availabilities", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean "available"
    t.string "available_for_type", null: false
    t.integer "available_for_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available_for_type", "available_for_id"], name: "index_availabilities_on_available_for"
  end

  create_table "charts", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "figure_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "movement"
    t.string "timing"
    t.text "partnering"
    t.index ["figure_id"], name: "index_charts_on_figure_id"
    t.index ["student_id"], name: "index_charts_on_student_id"
  end

  create_table "figures", force: :cascade do |t|
    t.string "name"
    t.string "dance"
    t.string "number"
    t.integer "bars"
    t.text "components"
    t.boolean "core"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "level"
  end

  create_table "lessons", force: :cascade do |t|
    t.datetime "start_time"
    t.integer "student_id", null: false
    t.integer "teacher_id", null: false
    t.text "plan"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location_id", null: false
    t.index ["location_id"], name: "index_lessons_on_location_id"
    t.index ["student_id"], name: "index_lessons_on_student_id"
    t.index ["teacher_id"], name: "index_lessons_on_teacher_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.float "rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "students", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "teachers", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "student", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "charts", "figures"
  add_foreign_key "charts", "students"
  add_foreign_key "lessons", "locations"
  add_foreign_key "lessons", "students"
  add_foreign_key "lessons", "teachers"
end
