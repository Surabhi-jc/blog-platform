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

ActiveRecord::Schema[8.0].define(version: 2025_09_23_103225) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "blog_tags", force: :cascade do |t|
    t.bigint "blog_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blog_id", "tag_id"], name: "index_blog_tags_on_blog_id_and_tag_id"
    t.index ["blog_id"], name: "index_blog_tags_on_blog_id"
    t.index ["tag_id", "blog_id"], name: "index_blog_tags_on_tag_id_and_blog_id"
    t.index ["tag_id"], name: "index_blog_tags_on_tag_id"
  end

  create_table "blogs", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes_count", default: 0, null: false
    t.datetime "deleted_at"
    t.bigint "deleted_by_id"
    t.integer "comments_count", default: 0, null: false
    t.index ["created_at", "id"], name: "idx_blogs_not_deleted_created_id", order: :desc, where: "(deleted_at IS NULL)"
    t.index ["deleted_at"], name: "index_blogs_on_deleted_at"
    t.index ["deleted_by_id"], name: "index_blogs_on_deleted_by_id"
    t.index ["likes_count"], name: "index_blogs_on_likes_count"
    t.index ["user_id"], name: "index_blogs_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "user_id", null: false
    t.bigint "blog_id", null: false
    t.bigint "parent_comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "deleted_by_id"
    t.index ["blog_id"], name: "index_comments_on_blog_id"
    t.index ["deleted_at"], name: "index_comments_on_deleted_at"
    t.index ["deleted_by_id"], name: "index_comments_on_deleted_by_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followed_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_and_followed", unique: true
    t.check_constraint "follower_id <> followed_id", name: "follows_no_self_follow"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "blog_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blog_id"], name: "index_likes_on_blog_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_tags", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_user_tags_on_tag_id"
    t.index ["user_id"], name: "index_user_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "is_admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "blog_tags", "blogs"
  add_foreign_key "blog_tags", "tags"
  add_foreign_key "blogs", "users"
  add_foreign_key "blogs", "users", column: "deleted_by_id"
  add_foreign_key "comments", "blogs"
  add_foreign_key "comments", "comments", column: "parent_comment_id"
  add_foreign_key "comments", "users"
  add_foreign_key "comments", "users", column: "deleted_by_id"
  add_foreign_key "follows", "users", column: "followed_id", on_delete: :cascade
  add_foreign_key "follows", "users", column: "follower_id", on_delete: :cascade
  add_foreign_key "likes", "blogs"
  add_foreign_key "likes", "users"
  add_foreign_key "user_tags", "tags"
  add_foreign_key "user_tags", "users"
end
