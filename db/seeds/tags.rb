# db/seeds/tags.rb
puts "Seeding tags..."

tag_names = [
  "gaming",
  "sports",
  "politics",
  "nature",
  "food",
  "fashion",
  "education",
  "music",
  "finance",
  "movies",
  "lifestyle"
]

tags = tag_names.map do |tag|
  { name: tag, created_at: Time.now, updated_at: Time.now }
end

Tag.insert_all(tags)

puts "✅ #{tag_names.size} tags created"
