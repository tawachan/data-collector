# frozen_string_literal: true

class TwitterRegisterRelationshipsJob < ApplicationJob
  queue_as :default

  def perform(twitter_screen_name)
    twitter_client = TwitterClient.new
    slack_client = SlackClient.new

    slack_client.info('ジョブが開始されました', "@#{twitter_screen_name}の情報取得が開始されました")

    # 自分
    twitter_me = twitter_client.fetch_user(twitter_screen_name)
    TwitterUser.register_or_update!(twitter_me)
    me = TwitterUser.find_by(twitter_id: twitter_me.id)

    # フォロー
    twitter_friend_ids = twitter_client.fetch_friend_ids_of(twitter_screen_name)

    twitter_target_ids = twitter_friend_ids.reject { |twitter_id| TwitterUser.exists?(twitter_id: twitter_id) }

    twitter_target_ids.each_slice(100) do |ids|
      users = twitter_client.fetch_users(ids)
      users.each do |user|
        TwitterUser.register_or_update!(user)
      end
    end

    ActiveRecord::Base.transaction do
      TwitterRelationship.where(follower_id: me.id).each(&:destroy!)
      twitter_friend_ids.each_with_index do |twitter_id, index|
        u = TwitterUser.find_by(twitter_id: twitter_id)
        next if u.nil?

        TwitterRegisterRelationshipsJob.set(wait: 15.minutes * index).perform_later(u.screen_name)

        next if TwitterRelationship.exists?(follower_id: me.id, followed_id: u.id)

        TwitterRelationship.create!(follower_id: me.id, followed_id: u.id)
      end
    end

    # フォロワー
    twitter_follower_ids = twitter_client.fetch_follower_ids_of(twitter_screen_name)

    twitter_target_ids = twitter_follower_ids.reject { |twitter_id| TwitterUser.exists?(twitter_id: twitter_id) }

    twitter_target_ids.each_slice(100) do |ids|
      users = twitter_client.fetch_users(ids)
      users.each do |user|
        TwitterUser.register_or_update!(user)
      end
    end

    ActiveRecord::Base.transaction do
      TwitterRelationship.where(followed_id: me.id).each(&:destroy!)
      twitter_follower_ids.each_with_index do |twitter_id, index|
        u = TwitterUser.find_by(twitter_id: twitter_id)
        next if u.nil?

        TwitterRegisterRelationshipsJob.set(wait: 15.minutes * index).perform_later(u.screen_name)
        next if TwitterRelationship.exists?(follower_id: u.id, followed_id: me.id)

        TwitterRelationship.create!(follower_id: u.id, followed_id: me.id)
      end
    end

    user_count = TwitterUser.all.count
    relationship_count = TwitterRelationship.all.count
    slack_client.info('ジョブが終了されました', '正常に終わってよかった', user_count, relationship_count, me)
  rescue Twitter::Error::TooManyRequests => e
    logger.error(e)
    slack_client.error('ジョブが異常終了しました', "15分後に再度実行します。（#{e.message}）")
    TwitterRegisterRelationshipsJob.set(wait: 15.minutes).perform_later(twitter_screen_name)
  end
end
