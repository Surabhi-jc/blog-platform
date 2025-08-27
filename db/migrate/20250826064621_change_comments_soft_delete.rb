class ChangeCommentsSoftDelete < ActiveRecord::Migration[8.0]
  def change
    # Add deleted_at column
    add_column :comments, :deleted_at, :datetime

    # Add index on deleted_at for paranoia performance
    add_index :comments, :deleted_at

    # Remove old is_deleted boolean
    remove_column :comments, :is_deleted, :boolean, default: false, null: false
  end
end
