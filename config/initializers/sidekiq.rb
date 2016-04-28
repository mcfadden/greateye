Sidekiq.configure_server do |config|
  config.redis = { namespace: 'great-eye' }
end

Sidekiq.configure_client do |config|
  config.redis = { namespace: 'great-eye', size: 1}
end