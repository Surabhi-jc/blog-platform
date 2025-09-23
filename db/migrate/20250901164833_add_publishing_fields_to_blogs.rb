class AddPublishingFieldsToBlogs < ActiveRecord::Migration[8.0]
  def change
    add_column :blogs, :status, :string, null: false, default: "draft"
    add_column :blogs, :scheduled_at, :datetime
    add_column :blogs, :published_at, :datetime

    add_index :blogs, :status
    add_index :blogs, :scheduled_at  #fast lookup for Sidekiq to publish blog
    add_index :blogs, :published_at  #sorting by most recent published
  end
end
