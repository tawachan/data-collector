# frozen_string_literal: true

class CreateTwitterRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :twitter_relationships do |t|
      t.references :followed, foreign_key: { to_table: :twitter_users }
      t.references :follower, foreign_key: { to_table: :twitter_users }
      t.timestamps

      t.index %i[followed_id follower_id], unique: true
    end
  end
end
