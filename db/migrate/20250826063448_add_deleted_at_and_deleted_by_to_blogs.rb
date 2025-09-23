class AddDeletedAtAndDeletedByToBlogs < ActiveRecord::Migration[8.0]
  def change
    add_column :blogs, :deleted_at, :datetime
    add_index :blogs, :deleted_at
    add_column :blogs, :deleted_by, :bigint
    add_index :blogs, :deleted_by
    add_foreign_key :blogs, :users, column: :deleted_by
  end
end
