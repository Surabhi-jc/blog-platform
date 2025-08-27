class AddForeignKeyToBlogsDeletedBy < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :blogs, :users, column: :deleted_by_id
  end
end
