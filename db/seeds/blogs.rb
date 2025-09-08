# db/seeds/blogs.rb
puts "Seeding blogs (this may take a while)..."

user_ids = User.pluck(:id)
tag_ids  = Tag.pluck(:id)

blogs = []
blog_tags = []

200_000.times do |i|
  blogs << {
    title: "Title #{i+1}",
    content: "Content #{i+1}",
    user_id: user_ids.sample,
    created_at: rand(7.days).seconds.ago,
    updated_at: Time.now
  }

  # Insert blogs in batches of 5000 for speed
  if blogs.size >= 5000
    inserted = Blog.insert_all(blogs, returning: %w[id])
    inserted_ids = inserted.rows.flatten

    # Assign 1–3 random tags per blog
    inserted_ids.each do |blog_id|
      rand(1..3).times do
        blog_tags << { blog_id: blog_id, tag_id: tag_ids.sample }
      end
    end

    BlogTag.insert_all(blog_tags) if blog_tags.any?
    blogs.clear
    blog_tags.clear
  end
end

# Insert leftovers
if blogs.any?
  inserted = Blog.insert_all(blogs, returning: %w[id])
  inserted_ids = inserted.rows.flatten
  inserted_ids.each do |blog_id|
    rand(1..3).times do
      blog_tags << { blog_id: blog_id, tag_id: tag_ids.sample }
    end
  end
  BlogTag.insert_all(blog_tags) if blog_tags.any?
end

puts "✅ 200,000 blogs created with random users + random tags"
