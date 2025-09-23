class User < ApplicationRecord
  has_many :blogs
  has_many :user_tags
  has_many :likes
  has_many :liked_blogs, through: :likes, source: :blog

  def admin?
    is_admin
  end
  
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, on: :create
  validates :password, confirmation: true, on: :create, length: { minimum: 6 }

  # People the user is following
  has_many :active_follows, class_name: "Follow",
           foreign_key: "follower_id"

  has_many :following, through: :active_follows, source: :followed

  # People who follow this user
  has_many :passive_follows, class_name: "Follow",
           foreign_key: "followed_id"

  has_many :followers, through: :passive_follows, source: :follower
  
end
