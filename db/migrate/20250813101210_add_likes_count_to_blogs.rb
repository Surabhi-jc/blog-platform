class AddLikesCountToBlogs < ActiveRecord::Migration[8.0]
  def change
    add_column :blogs, :likes_count, :integer, default: 0, null: false
    add_index :blogs, :likes_count
    # Ensure likes table has an index for blog_id if not already:
    add_index :likes, :blog_id unless index_exists?(:likes, :blog_id)
  end
end
