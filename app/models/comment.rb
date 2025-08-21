class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :blog

  #self reference association for nested comments
  belongs_to :parent_comment, class_name: "Comment", optional: true
  has_many   :replies, class_name: "Comment", foreign_key: "parent_comment_id"

  validates :content, presence: true, unless: :is_deleted?
  validates :user_id, presence: true
  validates :blog_id, presence: true

  def soft_delete
    update(is_deleted: true)
  end

  def display_content
    is_deleted? ? "Comment deleted" : content
  end
end
