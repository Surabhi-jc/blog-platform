class AddCommentsCountToBlogs < ActiveRecord::Migration[8.0]
  def change
    add_column :blogs, :comments_count, :integer, default: 0, null: false
  end
end
