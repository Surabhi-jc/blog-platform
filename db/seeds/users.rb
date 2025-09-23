# db/seeds/users.rb
require "bcrypt"

puts "Seeding users..."

hashed_pw = BCrypt::Password.create("password")

users = []
100.times do |i|
  users << {
    name: "User #{i+1}",
    email: "user#{i+1}@testing.com",
    password_digest: hashed_pw,
    is_admin: (i == 0), # First user is admin
    created_at: Time.now,
    updated_at: Time.now
  }
end

User.insert_all(users)
puts "✅ 100 users created"
