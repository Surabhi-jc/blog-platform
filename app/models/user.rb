class User < ApplicationRecord
  has_many :blogs
  
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, confirmation: true, length: { minimum: 6 }
  
end
