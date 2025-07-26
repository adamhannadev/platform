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

ActiveRecord::Schema[7.2].define(version: 2025_07_26_051428) do
  create_table "availabilities", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean "available"
    t.string "available_for_type", null: false
    t.integer "available_for_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_recurring", default: false
    t.integer "parent_availability_id"
    t.date "recurrence_end_date"
    t.date "instance_date"
    t.index ["available_for_type", "available_for_id"], name: "index_availabilities_on_available_for"
    t.index ["is_recurring"], name: "index_availabilities_on_is_recurring"
    t.index ["parent_availability_id", "instance_date"], name: "idx_on_parent_availability_id_instance_date_d77cc1c8e2"
    t.index ["parent_availability_id"], name: "index_availabilities_on_parent_availability_id"
  end

  create_table "booking_requests", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "teacher_id", null: false
    t.integer "location_id", null: false
    t.datetime "requested_start_time", null: false
    t.integer "duration", default: 45, null: false
    t.string "status", default: "pending", null: false
    t.text "notes"
    t.integer "approved_by_id"
    t.datetime "approved_at"
    t.text "rejection_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_id"], name: "index_booking_requests_on_approved_by_id"
    t.index ["location_id"], name: "index_booking_requests_on_location_id"
    t.index ["status"], name: "index_booking_requests_on_status"
    t.index ["student_id", "status"], name: "index_booking_requests_on_student_id_and_status"
    t.index ["student_id"], name: "index_booking_requests_on_student_id"
    t.index ["teacher_id", "requested_start_time"], name: "index_booking_requests_on_teacher_id_and_requested_start_time"
    t.index ["teacher_id"], name: "index_booking_requests_on_teacher_id"
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

  create_table "lesson_series", force: :cascade do |t|
    t.string "title", null: false
    t.integer "teacher_id", null: false
    t.integer "student_id", null: false
    t.integer "location_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "day_of_week", null: false
    t.time "time_of_day", null: false
    t.integer "duration", default: 45, null: false
    t.string "status", default: "active", null: false
    t.text "notes"
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_lesson_series_on_created_by_id"
    t.index ["location_id"], name: "index_lesson_series_on_location_id"
    t.index ["status"], name: "index_lesson_series_on_status"
    t.index ["student_id", "status"], name: "index_lesson_series_on_student_id_and_status"
    t.index ["student_id"], name: "index_lesson_series_on_student_id"
    t.index ["teacher_id", "day_of_week", "time_of_day"], name: "idx_on_teacher_id_day_of_week_time_of_day_955a7ceb92"
    t.index ["teacher_id"], name: "index_lesson_series_on_teacher_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.datetime "start_time"
    t.integer "student_id", null: false
    t.integer "teacher_id", null: false
    t.text "plan"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location_id", null: false
    t.integer "duration", default: 45, null: false
    t.string "status", default: "scheduled", null: false
    t.string "lesson_type", default: "private", null: false
    t.integer "availability_id"
    t.integer "booking_request_id"
    t.datetime "cancelled_at"
    t.text "cancellation_reason"
    t.decimal "rate_charged", precision: 8, scale: 2
    t.decimal "teacher_pay", precision: 8, scale: 2
    t.integer "lesson_series_id"
    t.integer "series_instance_number"
    t.boolean "is_makeup_lesson", default: false
    t.index ["availability_id"], name: "index_lessons_on_availability_id"
    t.index ["booking_request_id"], name: "index_lessons_on_booking_request_id"
    t.index ["lesson_series_id", "series_instance_number"], name: "index_lessons_on_lesson_series_id_and_series_instance_number"
    t.index ["lesson_series_id"], name: "index_lessons_on_lesson_series_id"
    t.index ["location_id"], name: "index_lessons_on_location_id"
    t.index ["status"], name: "index_lessons_on_status"
    t.index ["student_id", "start_time"], name: "index_lessons_on_student_id_and_start_time"
    t.index ["student_id"], name: "index_lessons_on_student_id"
    t.index ["teacher_id", "start_time"], name: "index_lessons_on_teacher_id_and_start_time"
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
    t.decimal "hourly_rate", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "student_rate", precision: 8, scale: 2, default: "0.0", null: false
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

  add_foreign_key "availabilities", "availabilities", column: "parent_availability_id"
  add_foreign_key "booking_requests", "locations"
  add_foreign_key "booking_requests", "students"
  add_foreign_key "booking_requests", "teachers"
  add_foreign_key "booking_requests", "users", column: "approved_by_id"
  add_foreign_key "charts", "figures"
  add_foreign_key "charts", "students"
  add_foreign_key "lesson_series", "locations"
  add_foreign_key "lesson_series", "students"
  add_foreign_key "lesson_series", "teachers"
  add_foreign_key "lesson_series", "users", column: "created_by_id"
  add_foreign_key "lessons", "availabilities"
  add_foreign_key "lessons", "booking_requests"
  add_foreign_key "lessons", "lesson_series"
  add_foreign_key "lessons", "locations"
  add_foreign_key "lessons", "students"
  add_foreign_key "lessons", "teachers"
end
