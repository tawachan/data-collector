# frozen_string_literal: true

class TwitterUser < ApplicationRecord
  has_many :follower_relationships, foreign_key: 'follower_id', class_name: 'TwitterRelationship', dependent: :destroy
  has_many :followings, through: :follower_relationships, source: :follower
  has_many :followed_relationships, foreign_key: 'followed_id', class_name: 'TwitterRelationship', dependent: :destroy
  has_many :followers, through: :followed_relationships, source: :followed

  validates :twitter_id, uniqueness: true

  def self.register_or_update!(twitter_user)
    if exists?(twitter_id: twitter_user.id)
      update!(twitter_user)
    else
      register!(twitter_user)
    end
  end

  def self.register!(twitter_user)
    create!(
      twitter_id: twitter_user.id,
      screen_name: twitter_user.screen_name,
      name: twitter_user.name,
      registed_at: twitter_user.created_at,
      location: twitter_user.location,
      description: twitter_user.description,
      url: twitter_user.url,
      profile_image_url: twitter_user.profile_image_url_https,
      profile_banner_url: twitter_user.profile_banner_url,
      followers_count: twitter_user.followers_count,
      friends_count: twitter_user.friends_count,
      favourites_count: twitter_user.favourites_count,
      statuses_count: twitter_user.statuses_count,
      listed_count: twitter_user.listed_count
    )
  end

  def self.update!(twitter_user)
    # ID以外は更新
    find_by!(twitter_id: twitter_user.id)
      .update!(
        screen_name: twitter_user.screen_name,
        name: twitter_user.name,
        registed_at: twitter_user.created_at,
        location: twitter_user.location,
        description: twitter_user.description,
        url: twitter_user.url,
        profile_image_url: twitter_user.profile_image_url_https,
        profile_banner_url: twitter_user.profile_banner_url,
        followers_count: twitter_user.followers_count,
        friends_count: twitter_user.friends_count,
        favourites_count: twitter_user.favourites_count,
        statuses_count: twitter_user.statuses_count,
        listed_count: twitter_user.listed_count
      )
  end
end
