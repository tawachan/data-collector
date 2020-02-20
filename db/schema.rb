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

ActiveRecord::Schema.define(version: 2020_02_20_035900) do

  create_table "twitter_relationships", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "followed_id"
    t.bigint "follower_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["followed_id", "follower_id"], name: "index_twitter_relationships_on_followed_id_and_follower_id", unique: true
    t.index ["followed_id"], name: "index_twitter_relationships_on_followed_id"
    t.index ["follower_id"], name: "index_twitter_relationships_on_follower_id"
  end

  create_table "twitter_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "screen_name"
    t.bigint "twitter_id"
    t.string "name"
    t.string "registed_at"
    t.string "location"
    t.string "description"
    t.string "url"
    t.string "profile_image_url"
    t.string "profile_banner_url"
    t.bigint "followers_count", default: 0
    t.bigint "friends_count", default: 0
    t.bigint "favourites_count", default: 0
    t.bigint "statuses_count", default: 0
    t.bigint "listed_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["screen_name"], name: "index_twitter_users_on_screen_name"
    t.index ["twitter_id"], name: "index_twitter_users_on_twitter_id"
  end

  add_foreign_key "twitter_relationships", "twitter_users", column: "followed_id"
  add_foreign_key "twitter_relationships", "twitter_users", column: "follower_id"
end
