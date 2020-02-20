# frozen_string_literal: true

require 'twitter'

class TwitterClient
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.credentials[:twitter][:twitter_api_key]
      config.consumer_secret     = Rails.application.credentials[:twitter][:twitter_secret_key]
      config.access_token        = Rails.application.credentials[:twitter][:twitter_access_token]
      config.access_token_secret = Rails.application.credentials[:twitter][:twitter_access_token_secret]
    end
  end

  def fetch_user(screen_name)
    @client.user(screen_name)
  end

  # 1度に最大5000件
  def fetch_friend_ids_of(screen_name)
    ids ||= []
    data = @client.friend_ids(screen_name, count: 5000, cursor: cursor).attrs
    ids = ids.concat(data[:ids])
    p ids
    fetch_friend_ids_of(screen_name, data[:next_cursor]) if data[:next_cursor].zero?
  end

  # 1度に最大5000件
  def fetch_follower_ids_of(screen_name, cursor = nil)
    ids ||= []
    data = @client.follower_ids(screen_name, count: 5000, cursor: cursor).attrs
    ids = ids.concat(data[:ids])
    p ids
    p "next_cursor#{data[:next_cursor]}"
    fetch_follower_ids_of(screen_name, data[:next_cursor]) unless data[:next_cursor].zero?
  end

  # 1度に最大100件
  def fetch_users(user_ids)
    @client.users(user_id: user_ids.join(','))
  end
end
