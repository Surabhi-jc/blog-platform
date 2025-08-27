class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :blog
  belongs_to :deleted_by, class_name: "User", optional: true

  #self reference association for nested comments
  belongs_to :parent_comment, class_name: "Comment", optional: true
  has_many   :replies, class_name: "Comment", foreign_key: "parent_comment_id"

  validates :content, presence: true, unless: :deleted_at?
  validates :user_id, presence: true
  validates :blog_id, presence: true

  def soft_delete(by_user:)
    update(deleted_at: Time.current, deleted_by: by_user)
  end

  def restore
    update(deleted_at: nil)
  end
  def display_content
    deleted_at.present? ? "Comment deleted" : content
  end

  scope :active,  -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
end
