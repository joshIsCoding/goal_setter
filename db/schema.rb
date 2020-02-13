# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_02_13_125810) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "categories_goals", force: :cascade do |t|
    t.bigint "category_id"
    t.bigint "goal_id"
    t.index ["category_id"], name: "index_categories_goals_on_category_id"
    t.index ["goal_id"], name: "index_categories_goals_on_goal_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "contents", null: false
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "author_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
  end

  create_table "goals", force: :cascade do |t|
    t.string "title", null: false
    t.text "details"
    t.string "status", default: "Not Started", null: false
    t.boolean "public", default: false, null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "title"], name: "index_goals_on_user_id_and_title", unique: true
  end

  create_table "key_events", force: :cascade do |t|
    t.string "eventable_type", null: false
    t.bigint "eventable_id", null: false
    t.string "event_type", null: false
    t.bigint "instigator_id", null: false
    t.boolean "notifications_generated", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["eventable_type", "eventable_id"], name: "index_key_events_on_eventable_type_and_eventable_id"
    t.index ["instigator_id"], name: "index_key_events_on_instigator_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "key_event_id", null: false
    t.boolean "seen", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key_event_id", "user_id"], name: "index_notifications_on_key_event_id_and_user_id", unique: true
    t.index ["key_event_id"], name: "index_notifications_on_key_event_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_token", null: false
    t.bigint "user_id", null: false
    t.string "remote_ip"
    t.string "user_agent"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "browser"
    t.string "device"
    t.string "city"
    t.index ["session_token"], name: "index_sessions_on_session_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "up_votes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "goal_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["goal_id"], name: "index_up_votes_on_goal_id"
    t.index ["user_id", "goal_id"], name: "index_up_votes_on_user_id_and_goal_id", unique: true
    t.index ["user_id"], name: "index_up_votes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "password"
    t.string "password_digest", null: false
    t.string "session_token", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "up_votes_left", null: false
    t.index ["session_token"], name: "index_users_on_session_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "key_events", "users", column: "instigator_id"
  add_foreign_key "notifications", "key_events"
  add_foreign_key "notifications", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "up_votes", "goals"
  add_foreign_key "up_votes", "users"
end
