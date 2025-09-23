# $redis = Redis.new(host: "redis", port: 6379)

# config/initializers/redis.rb

redis_url = ENV['REDIS_URL'] || "redis://redis:6379"  # fallback for local Docker
$redis = Redis.new(url: redis_url)

