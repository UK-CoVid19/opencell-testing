redis_conf = { url: ENV.fetch("REDIS_URL") { 'redis://redis:6379/12' }, password: ENV.fetch("REDIS_PASSWORD") { nil } }

Sidekiq.configure_server do |config|
  config.redis = redis_conf
end

Sidekiq.configure_client do |config|
  config.redis = redis_conf
end