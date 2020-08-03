# frozen_string_literal: true

class CreateTweets < ActiveRecord::Migration[6.0]
  def change
    create_table :tweets do |t|
      t.bigint :tweet_id, null: false, index: true, unique: true
      t.bigint :original_tweet_id, null: true
      t.string :text, null: false
      t.boolean :is_reply, null: false, defalut: false
      t.boolean :is_quote, null: false, defalut: false
      t.boolean :is_retweet, null: false, defalut: false
      t.bigint :user_id, null: false
      t.string :user_name, null: false
      t.string :user_screen_name, null: false, index: true, unique: false
      t.integer :user_friends_count, null: false, default: 0
      t.integer :user_followers_count, null: false, default: 0
      t.string :lang, null: true
      t.integer :quote_count, null: false, default: 0
      t.integer :reply_count, null: false, default: 0
      t.integer :retweet_count, null: false, default: 0
      t.integer :favorite_count, null: false, default: 0
      t.string :hashtags, null: true
      t.string :tweeted_at, null: false
      t.timestamps
    end
  end
end
