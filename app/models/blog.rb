class Blog < ApplicationRecord
  belongs_to :user
  belongs_to :deleted_by, class_name: "User", optional: true


  has_many :blog_tags, dependent: :destroy
  has_many :tags, through: :blog_tags
  has_many :likes
  has_many :liked_by_users, through: :likes, source: :user
  has_many :comments

  def soft_delete(by_user:)
    update(deleted_at: Time.current, deleted_by: by_user)
  end

  def restore
    update(deleted_at: nil)
  end

  # Scope: only active blogs
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

end
