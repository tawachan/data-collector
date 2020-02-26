# frozen_string_literal: true

class TwitterRegisterRelationshipsJob < ApplicationJob
  queue_as :default
  # layer_count の数だけ、再帰的にデータを取得していく
  # rubocop:disable all
  def perform(twitter_screen_name_or_id, layer_count = '0')
    twitter_client = TwitterClient.new
    slack_client = SlackClient.new
    layer_count = layer_count.to_i

    # slack_client.info('ジョブが開始されました', "@#{twitter_screen_name_or_id}の情報取得が開始されました")

    # 自分
    twitter_me = twitter_client.fetch_user(twitter_screen_name_or_id)
    TwitterUser.register_or_update!(twitter_me)
    me = TwitterUser.find_by(twitter_id: twitter_me.id)

    # フォロー
    twitter_friend_ids = twitter_client.fetch_friend_ids_of(twitter_screen_name_or_id)
    p twitter_friend_ids.length
    # フォロワー
    twitter_follower_ids = twitter_client.fetch_follower_ids_of(twitter_screen_name_or_id)
    p twitter_follower_ids.length
    # 一意のユーザーIDを選択
    all_twitter_ids = TwitterUser.all.select(:twitter_id).map{ |u| u.twitter_id }
    
    twitter_target_ids = (twitter_friend_ids | twitter_follower_ids).reject { |twitter_id| twitter_id.in?(all_twitter_ids) }

    twitter_target_ids.each do |id|      
      TwitterUser.create!(twitter_id: id)
    rescue StandardError
      logger.error('既に登録されたユーザーです。', id, me)
    end

    ActiveRecord::Base.transaction do
      # 現在のフォローにいないリレーションを削除
      ids_to_delete = TwitterRelationship.where(follower_id: me.id).reject { |r| r.followed.twitter_id.in?(twitter_friend_ids) }
      TwitterRelationship.where(id: ids_to_delete).each(&:destroy!)
      twitter_friend_ids.each_with_index do |twitter_id, index|
        u = TwitterUser.find_by(twitter_id: twitter_id)
        next if u.nil?
        # TODO ここで毎回クエリ飛ばさなくても良いようにしたい
        next if TwitterRelationship.exists?(follower_id: me.id, followed_id: u.id)
        # 新規のみを登録
        TwitterRelationship.create!(follower_id: me.id, followed_id: u.id)
      end
    end


    ActiveRecord::Base.transaction do
      # 現在のフォロワーにいないリレーションを削除
      ids_to_delete = TwitterRelationship.where(followed_id: me.id).reject { |r| r.follower.twitter_id.in?(twitter_follower_ids) }
      TwitterRelationship.where(id: ids_to_delete).each(&:destroy!)
      twitter_follower_ids.each_with_index do |twitter_id, index|
        u = TwitterUser.find_by(twitter_id: twitter_id)
        next if u.nil?
        # TODO ここで毎回クエリ飛ばさなくても良いようにしたい
        next if TwitterRelationship.exists?(follower_id: u.id, followed_id: me.id)
        # 新規のみを登録
        TwitterRelationship.create!(follower_id: u.id, followed_id: me.id)
      end
    end

    if layer_count.positive?
      (twitter_friend_ids | twitter_follower_ids).each_with_index do |id, index|
        TwitterRegisterRelationshipsJob.set(wait: 15.minutes * (index / 10).floor).perform_later(id, layer_count - 1)
      end
    end

    user_count = TwitterUser.all.count
    relationship_count = TwitterRelationship.all.count
    slack_client.info('ジョブが終了されました', '正常に終わってよかった', user_count, relationship_count, me)
  rescue Twitter::Error::TooManyRequests => e
    logger.error(e)

    # queue_count = Sidekiq::ScheduledSet.new.size
    time_to_delay = 15 # * (queue_count + 1 / 10).ceil

    # slack_client.error('ジョブが異常終了しました', "#{time_to_delay}分後に再度実行します。（#{e.message}）", me)
    TwitterRegisterRelationshipsJob.set(wait: time_to_delay * 1.minute).perform_later(twitter_screen_name_or_id, layer_count)
  rescue StandardError => e
    logger.error(e)
    # slack_client.error('ジョブが異常終了しました。再度実行します。', e.backtrace.to_s, me)
    raise e
  end
  # rubocop:enable all
end
