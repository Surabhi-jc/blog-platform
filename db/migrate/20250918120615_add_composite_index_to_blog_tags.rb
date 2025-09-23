class AddCompositeIndexToBlogTags < ActiveRecord::Migration[8.0]
  def change
    add_index :blog_tags, [:blog_id, :tag_id], name: "index_blog_tags_on_blog_id_and_tag_id"
  end
end
