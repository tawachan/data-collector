# frozen_string_literal: true

class Api::TweetsController < ApplicationController
  def index
    Tweet.all
  end

  def create
    Tweet.create(create_params)
  end

  def create_params
    params.permit(
      :tweet_id, :text, :is_reply, :is_quote, :is_retweet, :original_tweet_id,
      :user_id, :user_name, :user_screen_name, :user_friends_count, :user_followers_count,
      :lang, :quote_count, :reply_count, :retweet_count, :favorite_count, :hashtags, :tweeted_at
    )
  end
end
