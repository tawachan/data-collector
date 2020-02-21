# frozen_string_literal: true

require 'twitter'

class TwitterClient
  def initialize
    @client = Twitter::REST::Client.new do |config|
      key = !Rails.env.production? ? :production : :development
      config.consumer_key        = Rails.application.credentials[key][:twitter_api_key]
      config.consumer_secret     = Rails.application.credentials[key][:twitter_secret_key]
      config.access_token        = Rails.application.credentials[key][:twitter_access_token]
      config.access_token_secret = Rails.application.credentials[key][:twitter_access_token_secret]
    end
  end

  def fetch_user(screen_name)
    @client.user(screen_name)
  end

  # 1度に最大5000件
  def fetch_friend_ids_of(screen_name, cursor = nil)
    ids ||= []
    data = @client.friend_ids(screen_name, count: 5000, cursor: cursor).attrs
    ids = ids.concat(data[:ids])
    fetch_friend_ids_of(screen_name, data[:next_cursor]) if data[:next_cursor].zero?
    ids
  end

  # 1度に最大5000件
  def fetch_follower_ids_of(screen_name, cursor = nil)
    ids ||= []
    data = @client.follower_ids(screen_name, count: 5000, cursor: cursor).attrs
    ids = ids.concat(data[:ids])
    fetch_follower_ids_of(screen_name, data[:next_cursor]) unless data[:next_cursor].zero?
    ids
  end

  # 1度に最大100件
  # それ以上渡してもいい感じに複数回リクエスト飛ばしてくれるらしい
  def fetch_users(user_ids)
    @client.users(user_ids)
  end
end
