# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('DATABASE_HOST') { 'redis://localhost:6379' } }
end
