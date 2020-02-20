# frozen_string_literal: true

class CreateTwitterUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :twitter_users do |t|
      # 検索に必要
      t.string :screen_name, require: true, index: true, unique: false # Twitterの仕様上変わることがあるから
      t.bigint :twitter_id, require: true, index: true, unique: true
      # 必ず存在する値
      t.string :name, require: true
      t.string :registed_at, require: true
      # オプショナル
      t.string :location, require: false
      t.string :description, require: false
      t.string :url, require: false
      t.string :profile_image_url, require: false
      t.string :profile_banner_url, require: false
      # 数値
      t.bigint :followers_count, require: true, default: 0
      t.bigint :friends_count, require: true, default: 0
      t.bigint :favourites_count, require: true, default: 0
      t.bigint :statuses_count, require: true, default: 0
      t.bigint :listed_count, require: true, default: 0

      t.timestamps
    end
  end
end
