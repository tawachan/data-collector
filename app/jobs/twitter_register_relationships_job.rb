# frozen_string_literal: true

class TwitterRegisterRelationshipsJob < ApplicationJob
  queue_as :default

  def perform(twitter_screen_name)
    client = TwitterClient.new

    # 自分
    me = client.fetch_user(twitter_screen_name)
    TwitterUser.register_or_update!(me)
    # フォロー
    friend_ids = client.fetch_friend_ids(twitter_screen_name)
    target_ids = friend_ids.reject { |id| TwitterUser.exists?(twitter_id: id) }
    target_ids.each_slice(100) do |ids|
      users = client.fetch_users(ids)
      users.each do |user|
        TwitterUser.register_or_update!(user)
      end
    end
    # フォロワー
    follower_ids = client.fetch_follower_ids(twitter_screen_name)
    target_ids = follower_ids.reject { |id| TwitterUser.exists?(twitter_id: id) }
    target_ids.each_slice(100) do |ids|
      users = client.fetch_users(ids)
      users.each do |user|
        TwitterUser.register_or_update!(user)
      end
    end
  rescue Twitter::Error::TooManyRequests => e
    logger.error(e)
    TwitterRegisterRelationshipsJob.wait(15.mins).perform_later(twitter_screen_name)
  end
end
