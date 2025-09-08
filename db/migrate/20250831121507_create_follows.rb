class CreateFollows < ActiveRecord::Migration[8.0]
  def change
    create_table :follows do |t|
      t.bigint :follower_id, null: false
      t.bigint :followed_id, null: false
      t.timestamps
    end

    # Foreign keys to users table
    add_foreign_key :follows, :users, column: :follower_id, on_delete: :cascade
    add_foreign_key :follows, :users, column: :followed_id, on_delete: :cascade

    # Indexes
    add_index :follows, [:follower_id, :followed_id], unique: true, name: "index_follows_on_follower_and_followed"
    add_index :follows, :followed_id

    # Prevent self-following
    add_check_constraint :follows, "follower_id <> followed_id", name: "follows_no_self_follow"
  end
end
