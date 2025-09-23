class RenameDeletedByToDeletedByIdInBlogs < ActiveRecord::Migration[8.0]
  def change
    rename_column :blogs, :deleted_by, :deleted_by_id

  end
end
