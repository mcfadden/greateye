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

ActiveRecord::Schema.define(version: 20150422031009) do

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
  end

  add_index "camera_events", ["camera_id"], name: "index_camera_events_on_camera_id", using: :btree
  add_index "camera_events", ["event_timestamp"], name: "index_camera_events_on_event_timestamp", using: :btree
  add_index "camera_events", ["keep"], name: "index_camera_events_on_keep", using: :btree
  add_index "camera_events", ["status"], name: "index_camera_events_on_status", using: :btree

  create_table "cameras", force: :cascade do |t|
    t.string   "name"
    t.integer  "model",      default: 0
    t.string   "username"
    t.string   "password"
    t.boolean  "active",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "host"
  end

  add_foreign_key "camera_event_assets", "camera_events"
  add_foreign_key "camera_events", "cameras"
end
