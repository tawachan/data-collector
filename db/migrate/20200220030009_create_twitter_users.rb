# frozen_string_literal: true

class CreateTwitterUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :twitter_users do |t|
      t.string :screen_name, require: true, index: true
      t.string :unique_id, require: true, index: true
      t.timestamps
    end
  end
end
