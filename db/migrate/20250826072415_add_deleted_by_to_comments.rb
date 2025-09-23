class AddDeletedByToComments < ActiveRecord::Migration[8.0]
  def change
    add_column :comments, :deleted_by, :bigint
    add_index :comments, :deleted_by
    add_foreign_key :comments, :users, column: :deleted_by
  end
end
