class RemoveDuplicateDeletedByForeignKeyFromBlogs < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :blogs, name: "fk_rails_1c58e2516e"
  end
end
