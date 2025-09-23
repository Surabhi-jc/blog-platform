require 'sidekiq'
require 'sidekiq/cron/job'

# redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')

redis_url = ENV['REDIS_URL'] || 'redis://redis:6379/0'

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  schedule_file = Rails.root.join('config/schedule.yml')
  if File.exist?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
