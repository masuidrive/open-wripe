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

ActiveRecord::Schema.define(version: 20131014145849) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chat_messages", force: true do |t|
    t.integer  "user_id"
    t.integer  "chatroom_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chat_messages", ["chatroom_id"], name: "index_chat_messages_on_chatroom_id", using: :btree

  create_table "chatroom_users", force: true do |t|
    t.integer  "chatroom_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chatroom_users", ["chatroom_id", "user_id"], name: "index_chatroom_users_on_chatroom_id_and_user_id", unique: true, using: :btree

  create_table "chatrooms", force: true do |t|
    t.string   "key"
    t.string   "name"
    t.string   "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chatrooms", ["user_id"], name: "index_chatrooms_on_user_id", using: :btree

  create_table "dropbox_users", force: true do |t|
    t.integer  "user_id"
    t.string   "auth_token"
    t.string   "auth_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "backups"
  end

  create_table "evernote_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "enid"
    t.string   "evernote_username"
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "notebook_guid"
  end

  add_index "evernote_users", ["enid"], name: "index_evernote_users_on_enid", unique: true, using: :btree
  add_index "evernote_users", ["user_id"], name: "index_evernote_users_on_user_id", unique: true, using: :btree

  create_table "fb_users", force: true do |t|
    t.integer  "user_id"
    t.text     "token"
    t.text     "json"
    t.text     "fbid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fb_users", ["user_id"], name: "index_fb_users_on_user_id", using: :btree

  create_table "feedbacks", force: true do |t|
    t.integer  "user_id"
    t.boolean  "closed"
    t.boolean  "opened"
    t.integer  "subject"
    t.text     "body"
    t.text     "admin_note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "user_agent"
  end

  add_index "feedbacks", ["closed", "created_at"], name: "index_feedbacks_on_closed_and_created_at", using: :btree
  add_index "feedbacks", ["closed", "subject", "created_at"], name: "index_feedbacks_on_closed_and_subject_and_created_at", using: :btree
  add_index "feedbacks", ["opened", "created_at"], name: "index_feedbacks_on_opened_and_created_at", using: :btree
  add_index "feedbacks", ["subject", "created_at"], name: "index_feedbacks_on_subject_and_created_at", using: :btree
  add_index "feedbacks", ["user_id", "created_at"], name: "index_feedbacks_on_user_id_and_created_at", using: :btree

  create_table "gh_users", force: true do |t|
    t.integer  "user_id"
    t.string   "ghid"
    t.text     "token"
    t.text     "name"
    t.text     "account"
    t.text     "json"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gh_users", ["user_id"], name: "index_gh_users_on_user_id", using: :btree

  create_table "helps", force: true do |t|
    t.integer  "user_id"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "helps", ["user_id", "key"], name: "index_helps_on_user_id_and_key", unique: true, using: :btree
  add_index "helps", ["user_id"], name: "index_helps_on_user_id", using: :btree

  create_table "page_dates", force: true do |t|
    t.integer  "page_id"
    t.integer  "user_id"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_dates", ["page_id"], name: "index_page_dates_on_page_id", using: :btree
  add_index "page_dates", ["user_id", "date"], name: "index_page_dates_on_user_id_and_date", using: :btree

  create_table "page_histories", force: true do |t|
    t.integer  "page_id"
    t.text     "body"
    t.text     "title"
    t.integer  "page_lock_version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_histories", ["page_id", "created_at"], name: "index_page_histories_on_page_id_and_created_at", using: :btree

  create_table "page_properties", force: true do |t|
    t.integer  "page_id"
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_properties", ["page_id", "key"], name: "index_page_properties_on_page_id_and_key", unique: true, using: :btree

  create_table "page_taggings", force: true do |t|
    t.integer  "page_id"
    t.integer  "page_tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_taggings", ["page_id", "page_tag_id"], name: "index_page_taggings_on_page_id_and_page_tag_id", unique: true, using: :btree

  create_table "page_tags", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page_taggings_count", default: 0
  end

  add_index "page_tags", ["user_id", "name"], name: "index_page_tags_on_user_id_and_name", unique: true, using: :btree
  add_index "page_tags", ["user_id", "page_taggings_count"], name: "index_page_tags_on_user_id_and_page_taggings_count", using: :btree

  create_table "page_users", force: true do |t|
    t.integer  "page_id"
    t.integer  "user_id"
    t.boolean  "read_permission",  default: true
    t.boolean  "write_permission", default: true
    t.boolean  "share_permission", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_users", ["page_id", "user_id"], name: "index_page_users_on_page_id_and_user_id", unique: true, using: :btree
  add_index "page_users", ["user_id"], name: "index_page_users_on_user_id", using: :btree

  create_table "pages", force: true do |t|
    t.integer  "user_id"
    t.text     "title"
    t.text     "body"
    t.string   "key"
    t.integer  "share_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "read_permission",  default: 0
    t.integer  "write_permission", default: 0
    t.integer  "lock_version",     default: 0
    t.boolean  "archived",         default: false
    t.integer  "modified_at"
  end

  add_index "pages", ["user_id", "archived", "modified_at"], name: "index_pages_on_user_id_and_archived_and_modified_at", using: :btree
  add_index "pages", ["user_id", "archived", "updated_at"], name: "index_pages_on_user_id_and_archived_and_updated_at", using: :btree
  add_index "pages", ["user_id", "modified_at"], name: "index_pages_on_user_id_and_modified_at", using: :btree
  add_index "pages", ["user_id", "updated_at"], name: "index_pages_on_user_id_and_updated_at", using: :btree

  create_table "user_messages", force: true do |t|
    t.integer  "user_id"
    t.integer  "page_id"
    t.boolean  "read",           default: false
    t.string   "message_type",   default: "free"
    t.text     "title"
    t.text     "body"
    t.text     "icon_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sender_user_id"
  end

  add_index "user_messages", ["user_id", "created_at"], name: "index_user_messages_on_user_id_and_created_at", using: :btree
  add_index "user_messages", ["user_id", "message_type", "created_at"], name: "idx_user_messages_4", using: :btree
  add_index "user_messages", ["user_id", "message_type", "read", "created_at"], name: "idx_user_messages_5", using: :btree
  add_index "user_messages", ["user_id", "page_id", "read", "created_at"], name: "idx_user_messages_3", using: :btree
  add_index "user_messages", ["user_id", "read", "created_at"], name: "index_user_messages_on_user_id_and_read_and_created_at", using: :btree
  add_index "user_messages", ["user_id", "sender_user_id", "created_at"], name: "idx_user_messages_6", using: :btree

  create_table "user_properties", force: true do |t|
    t.integer  "user_id"
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_properties", ["user_id", "key"], name: "index_user_properties_on_user_id_and_key", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "icon_url"
    t.datetime "actived_at"
    t.string   "email"
    t.boolean  "active",     default: true
  end

  add_index "users", ["active"], name: "index_users_on_active", using: :btree
  add_index "users", ["actived_at"], name: "index_users_on_actived_at", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
