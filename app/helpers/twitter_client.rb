# frozen_string_literal: true

require 'twitter'

class TwitterClient
  def initialize
    @client_development = Twitter::REST::Client.new do |config|
      key = :development
      config.consumer_key        = Rails.application.credentials[key][:twitter_api_key]
      config.consumer_secret     = Rails.application.credentials[key][:twitter_secret_key]
      config.access_token        = Rails.application.credentials[key][:twitter_access_token]
      config.access_token_secret = Rails.application.credentials[key][:twitter_access_token_secret]
    end

    @client_production = Twitter::REST::Client.new do |config|
      key = :production
      config.consumer_key        = Rails.application.credentials[key][:twitter_api_key]
      config.consumer_secret     = Rails.application.credentials[key][:twitter_secret_key]
      config.access_token        = Rails.application.credentials[key][:twitter_access_token]
      config.access_token_secret = Rails.application.credentials[key][:twitter_access_token_secret]
    end
  end

  def fetch_user(screen_name_or_id)
    default_client.user(screen_name_or_id)
  rescue Twitter::Error::TooManyRequests
    fallback_client.user(screen_name_or_id)
  end

  # 1度に最大5000件
  def fetch_friend_ids_of(screen_name, cursor = nil)
    data = default_client.friend_ids(screen_name, count: 5000, cursor: cursor).attrs
    ids = data[:ids]

    ids = ids.concat(fetch_friend_ids_of(screen_name, data[:next_cursor])) unless data[:next_cursor].zero?
    ids
  rescue Twitter::Error::TooManyRequests
    data = default_client.friend_ids(screen_name, count: 5000, cursor: cursor).attrs
    ids = data[:ids]

    ids = ids.concat(fetch_friend_ids_of(screen_name, data[:next_cursor])) unless data[:next_cursor].zero?
    ids
  end

  # 1度に最大5000件
  def fetch_follower_ids_of(screen_name, cursor = nil)
    data = default_client.follower_ids(screen_name, count: 5000, cursor: cursor).attrs
    ids = data[:ids]
    ids = ids.concat(fetch_follower_ids_of(screen_name, data[:next_cursor])) unless data[:next_cursor].zero?
    ids
  rescue Twitter::Error::TooManyRequests
    data = fallback_client.follower_ids(screen_name, count: 5000, cursor: cursor).attrs
    ids = data[:ids]
    ids = ids.concat(fetch_follower_ids_of(screen_name, data[:next_cursor])) unless data[:next_cursor].zero?
    ids
  end

  # 1度に最大100件
  # それ以上渡してもいい感じに複数回リクエスト飛ばしてくれるらしい
  def fetch_users(user_ids)
    default_client.users(user_ids)
  rescue Twitter::Error::TooManyRequests
    fallback_client.users(user_ids)
  end

  def default_client
    Rails.env.production? ? @client_production : @client_development
  end

  def fallback_client
    !Rails.env.production? ? @client_production : @client_development
  end
end
