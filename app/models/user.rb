class User < ApplicationRecord
  has_many :blogs
  has_many :user_tags
  has_many :likes
  has_many :liked_blogs, through: :likes, source: :blog
  
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, on: :create
  validates :password, confirmation: true, on: :create, length: { minimum: 6 }
  
end
