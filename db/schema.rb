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

ActiveRecord::Schema.define(version: 20130712135331) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_versions", force: true do |t|
    t.string   "name"
    t.string   "version"
    t.string   "url_ipa"
    t.string   "url_icon"
    t.string   "url_plist"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.string   "app_ipa_file_name"
    t.string   "app_ipa_content_type"
    t.integer  "app_ipa_file_size"
    t.datetime "app_ipa_updated_at"
    t.string   "version_icon_file_name"
    t.string   "version_icon_content_type"
    t.integer  "version_icon_file_size"
    t.datetime "version_icon_updated_at"
    t.string   "app_plist_file_name"
    t.string   "app_plist_content_type"
    t.integer  "app_plist_file_size"
    t.datetime "app_plist_updated_at"
  end

  create_table "projects", force: true do |t|
    t.string   "name",                      limit: 50, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "project_icon_file_name"
    t.string   "project_icon_content_type"
    t.integer  "project_icon_file_size"
    t.datetime "project_icon_updated_at"
    t.string   "bundle_identifier"
    t.string   "title"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
