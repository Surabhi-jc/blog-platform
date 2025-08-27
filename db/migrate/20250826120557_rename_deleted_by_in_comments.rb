class RenameDeletedByInComments < ActiveRecord::Migration[8.0]
  def change
    rename_column :comments, :deleted_by, :deleted_by_id
  end
end
