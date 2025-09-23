class AddPartialIndexOnBlogs < ActiveRecord::Migration[8.0]
  def change
    add_index :blogs,
              [:created_at, :id],
              order: {created_at: :desc, id: :desc},
              where: "deleted_at IS NULL",
              name: "idx_blogs_not_deleted_created_id"
  end
end
