# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_06_23_193033) do

  create_table "imported_files", force: :cascade do |t|
    t.string "filename"
    t.string "status"
    t.datetime "date"
    t.string "format"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_imported_files_on_user_id"
  end

  create_table "imported_records", force: :cascade do |t|
    t.string "column_1"
    t.string "column_2"
    t.string "column_3"
    t.string "column_4"
    t.string "column_5"
    t.string "column_6"
    t.string "column_7"
    t.integer "imported_files_id"
    t.integer "users_id"
    t.string "status"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["imported_files_id"], name: "index_imported_records_on_imported_files_id"
    t.index ["users_id"], name: "index_imported_records_on_users_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
