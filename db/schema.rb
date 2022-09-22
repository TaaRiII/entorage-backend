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

ActiveRecord::Schema.define(version: 2022_01_11_193754) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "ios_version"
    t.string "base_url"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "devices", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "fcm_token"
    t.string "physical_address"
    t.integer "device_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feed_backs", force: :cascade do |t|
    t.string "reason"
    t.string "phone_number"
    t.string "first_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "friend_id"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_statuses", force: :cascade do |t|
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name"
    t.string "icon_file_name"
    t.string "icon_content_type"
    t.integer "icon_file_size"
    t.datetime "icon_updated_at"
    t.integer "user_id"
    t.integer "status_type", default: 0
    t.datetime "discarded_at"
    t.integer "position"
    t.decimal "latitude", precision: 15, scale: 6
    t.decimal "longitude", precision: 15, scale: 6
    t.string "address"
    t.index ["discarded_at"], name: "index_group_statuses_on_discarded_at"
  end

  create_table "groups", force: :cascade do |t|
    t.integer "group_status_id"
    t.string "name"
    t.integer "status", default: 0
    t.decimal "latitude", precision: 15, scale: 6
    t.decimal "longitude", precision: 15, scale: 6
    t.string "city"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.integer "instant_match_allow", default: 1
    t.integer "spot_light_allow", default: 1
    t.boolean "spot_light_enabled", default: false
    t.datetime "spot_light_time"
    t.integer "place_id"
    t.integer "gender"
    t.integer "min_age"
    t.integer "max_age"
    t.integer "users_count"
    t.index ["gender"], name: "index_groups_on_gender"
    t.index ["group_status_id"], name: "index_groups_on_group_status_id"
    t.index ["max_age"], name: "index_groups_on_max_age"
    t.index ["min_age"], name: "index_groups_on_min_age"
    t.index ["spot_light_enabled"], name: "index_groups_on_spot_light_enabled"
    t.index ["users_count"], name: "index_groups_on_users_count"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "group_id"
    t.integer "matcher_id"
    t.integer "status"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "chat_id"
    t.boolean "instant", default: false
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.text "message"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "photos", id: :serial, force: :cascade do |t|
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.integer "user_id"
    t.integer "order", default: 0
    t.boolean "is_primary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_ever_primary", default: false
    t.index ["user_id"], name: "index_photos_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.integer "user_id"
    t.integer "reporter_id"
    t.integer "status"
    t.text "reason"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "report_type", default: 0
  end

  create_table "settings", force: :cascade do |t|
    t.integer "user_id"
    t.boolean "everyone", default: false
    t.boolean "male_only", default: false
    t.boolean "interest_based_match", default: false
    t.integer "min_age", default: 18
    t.integer "max_age", default: 30
    t.integer "group_member_count"
    t.integer "max_distace", default: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "general", default: true
    t.boolean "friendship", default: true
    t.boolean "match", default: true
    t.boolean "group", default: true
    t.boolean "chat", default: true
    t.boolean "female_only", default: false
  end

  create_table "user_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.boolean "creator", default: false
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_notifications", force: :cascade do |t|
    t.integer "user_id"
    t.integer "notification_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "phone_number"
    t.string "user_name"
    t.string "authentication_token"
    t.string "first_name"
    t.string "last_name"
    t.text "bio"
    t.date "dob"
    t.integer "age"
    t.integer "gender"
    t.integer "group_id"
    t.decimal "latitude", precision: 15, scale: 6
    t.decimal "longitude", precision: 15, scale: 6
    t.string "city"
    t.string "state"
    t.boolean "creator", default: false
    t.boolean "is_premium", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "instant_match_allow", default: 1
    t.integer "spot_light_allow", default: 1
    t.boolean "is_blocked", default: false
    t.boolean "is_new", default: true
    t.datetime "last_used"
    t.index ["authentication_token"], name: "index_users_on_authentication_token"
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
    t.index ["user_name"], name: "index_users_on_user_name", unique: true
  end

end
