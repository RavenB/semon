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

ActiveRecord::Schema.define(version: 20150623014933) do

  create_table "campaigns", force: true do |t|
    t.string   "c_name",                    null: false
    t.string   "c_description"
    t.datetime "c_start",                   null: false
    t.datetime "c_end",                     null: false
    t.integer  "c_status",      default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaigns", ["c_name"], name: "index_campaigns_on_c_name", unique: true, using: :btree

  create_table "categories", force: true do |t|
    t.string   "cat_name",        null: false
    t.string   "cat_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_tags", force: true do |t|
    t.integer  "message_id", null: false
    t.integer  "tag_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "message_tags", ["message_id"], name: "index_message_tags_on_message_id", using: :btree
  add_index "message_tags", ["tag_id"], name: "index_message_tags_on_tag_id", using: :btree

  create_table "messages", force: true do |t|
    t.string   "m_author",     null: false
    t.text     "m_text",       null: false
    t.datetime "m_moment",     null: false
    t.string   "m_origin",     null: false
    t.text     "m_details"
    t.integer  "m_rating"
    t.integer  "campaign_id",  null: false
    t.integer  "category_id"
    t.integer  "sentiment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["campaign_id"], name: "index_messages_on_campaign_id", using: :btree
  add_index "messages", ["category_id"], name: "index_messages_on_category_id", using: :btree
  add_index "messages", ["sentiment_id"], name: "index_messages_on_sentiment_id", using: :btree

  create_table "sentiments", force: true do |t|
    t.string   "s_name",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.string   "t_name",                   null: false
    t.string   "ancestry"
    t.integer  "t_count",      default: 0, null: false
    t.string   "t_connection"
    t.integer  "campaign_id",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["ancestry"], name: "index_tags_on_ancestry", using: :btree
  add_index "tags", ["campaign_id"], name: "index_tags_on_campaign_id", using: :btree

end
