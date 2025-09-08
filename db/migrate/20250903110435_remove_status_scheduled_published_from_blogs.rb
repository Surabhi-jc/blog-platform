class RemoveStatusScheduledPublishedFromBlogs < ActiveRecord::Migration[8.0]
  def change
    remove_column :blogs, :status, :string
    remove_column :blogs, :scheduled_at, :datetime
    remove_column :blogs, :published_at, :datetime
  end
end
