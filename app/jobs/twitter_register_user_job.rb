# frozen_string_literal: true

class TwitterRegisterUserJob < ApplicationJob
  queue_as :default

  def perform(twitter_screen_name)
    client = TwitterClient.new
    user = client.fetch_user(twitter_screen_name)
    if TwitterUser.exists?(twitter_id: user.id)
      TwitterUser.update!(user)
    else
      TwitterUser.register!(user)
    end
  end
end
