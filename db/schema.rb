# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170321235542) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "camera_event_assets", force: :cascade do |t|
    t.integer  "camera_event_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "asset_filename"
    t.text     "asset_file_path"
    t.integer  "asset_size"
    t.text     "asset_original_filename"
    t.boolean  "asset_stored_privately"
    t.string   "asset_type"
    t.integer  "status",                  default: 0
  end

  add_index "camera_event_assets", ["asset_type"], name: "index_camera_event_assets_on_asset_type", using: :btree
  add_index "camera_event_assets", ["camera_event_id"], name: "index_camera_event_assets_on_camera_event_id", using: :btree
  add_index "camera_event_assets", ["status"], name: "index_camera_event_assets_on_status", using: :btree

  create_table "camera_events", force: :cascade do |t|
    t.integer  "camera_id"
    t.integer  "event_type",      default: 0
    t.datetime "event_timestamp"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "status",          default: 0
    t.boolean  "keep",            default: false
    t.integer  "duration"
  end

  add_index "camera_events", ["camera_id"], name: "index_camera_events_on_camera_id", using: :btree
  add_index "camera_events", ["event_timestamp"], name: "index_camera_events_on_event_timestamp", using: :btree
  add_index "camera_events", ["keep"], name: "index_camera_events_on_keep", using: :btree
  add_index "camera_events", ["status"], name: "index_camera_events_on_status", using: :btree

  create_table "cameras", force: :cascade do |t|
    t.string   "name"
    t.string   "username"
    t.string   "password"
    t.boolean  "active",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "host"
    t.string   "make"
    t.string   "model"
  end

  add_index "cameras", ["make", "model"], name: "index_cameras_on_make_and_model", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "camera_event_assets", "camera_events"
  add_foreign_key "camera_events", "cameras"
end
