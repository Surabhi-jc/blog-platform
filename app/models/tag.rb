class Tag < ApplicationRecord
    has_many :blog_tags, dependent: :destroy
    has_many :blogs, through: :blog_tags
    has_many :user_tags
    has_many :users, through: :user_tags
end
