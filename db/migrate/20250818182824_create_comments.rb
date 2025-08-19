class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.text    :content, null: false
      t.boolean :is_deleted, null: false, default: false

      t.references :user, null: false, foreign_key: true
      t.references :blog, null: false, foreign_key: true

      # parent comment for nesting (nullable = top-level comment)
      t.bigint :parent_comment_id, null: true

      t.timestamps
    end

    # Foreign key to self for nesting
    add_foreign_key :comments, :comments, column: :parent_comment_id



  end
end
