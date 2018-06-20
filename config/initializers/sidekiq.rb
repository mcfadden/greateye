Sidekiq.configure_server do |config|
  config.redis = { host: ENV['REDIS_HOST'] || 'localhost', namespace: 'great-eye' }
end

Sidekiq.configure_client do |config|
  config.redis = { host: ENV['REDIS_HOST'] || 'localhost', namespace: 'great-eye', size: 1}
end
