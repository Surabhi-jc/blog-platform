class Blog < ApplicationRecord
  belongs_to :user
  has_many :blog_tags, dependent: :destroy
  has_many :tags, through: :blog_tags
  has_many :likes
  has_many :liked_by_users, through: :likes, source: :user
  
end
