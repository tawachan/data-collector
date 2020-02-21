# frozen_string_literal: true

class TwitterRegisterRelationshipsJob < ApplicationJob
  queue_as :default

  def perform(twitter_screen_name)
    client = TwitterClient.new

    # 自分
    logger.info('start me')
    me = client.fetch_user(twitter_screen_name)
    TwitterUser.register_or_update!(me)
    logger.info('end me')
    # フォロー
    logger.info('start follow')
    friend_ids = client.fetch_friend_ids_of(twitter_screen_name)
    logger.info("all_ids: #{friend_ids.length}")
    target_ids = friend_ids.reject { |id| TwitterUser.exists?(twitter_id: id) }
    logger.info("target_ids: #{target_ids.length}")
    target_ids.each_slice(100) do |ids|
      users = client.fetch_users(ids)
      users.each do |user|
        TwitterUser.register_or_update!(user)
      end
    end
    logger.info('end follow')
    # フォロワー
    logger.info('start followwer')
    follower_ids = client.fetch_follower_ids_of(twitter_screen_name)
    logger.info("all_ids: #{follower_ids.length}")
    target_ids = follower_ids.reject { |id| TwitterUser.exists?(twitter_id: id) }
    logger.info("target_ids: #{target_ids.length}")
    target_ids.each_slice(100) do |ids|
      users = client.fetch_users(ids)
      users.each do |user|
        TwitterUser.register_or_update!(user)
      end
    end
    logger.info('end followwer')
  rescue Twitter::Error::TooManyRequests => e
    logger.error(e)
    TwitterRegisterRelationshipsJob.set(wait: 15.minutes).perform_later(twitter_screen_name)
  end
end
