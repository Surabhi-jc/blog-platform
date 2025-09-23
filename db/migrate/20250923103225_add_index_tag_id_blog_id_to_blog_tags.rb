class AddIndexTagIdBlogIdToBlogTags < ActiveRecord::Migration[8.0]
  def change
    add_index :blog_tags, [:tag_id, :blog_id], name: "index_blog_tags_on_tag_id_and_blog_id"
  end
end
