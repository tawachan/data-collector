# frozen_string_literal: true

require 'slack/incoming/webhooks'

class SlackClient
  def initialize
    @client = Slack::Incoming::Webhooks.new(Rails.application.credentials[:slack_url], username: 'twitter-collector',
                                                                                       channel: '#twitter-collection')
  end

  def info(title, message, user_count = nil, relationship_count = nil, user = nil)
    fields_hidden = user_count.nil? || relationship_count.nil?
    fields = [
      {
        title: 'フォロー数',
        value: user&.followings&.count,
        short: true
      }, {
        title: 'フォロワー数',
        value: user&.followers&.count,
        short: true
      }, {
        title: 'ユーザー数合計',
        value: user_count,
        short: true
      }, {
        title: 'FF関係合計',
        value: relationship_count,
        short: true
      }
    ]

    @client.post "【#{Rails.env.production? ? '本番' : '開発'}】Twitter Collector", attachments: [{
      title: title,
      title_link: "#{Rails.application.credentials[:domain]}/sidekiq",
      author_name: user&.screen_name,
      author_link: user&.url,
      author_icon: user&.profile_image_url,
      text: message,
      color: '#7CD197',
      fields: fields_hidden ? nil : fields
    }]
  end

  def error(title, message, user = nil)
    @client.post "【#{Rails.env.production? ? '本番' : '開発'}】Twitter Collector", attachments: [{
      title: title,
      title_link: "#{Rails.application.credentials[:domain]}/sidekiq",
      author_name: user&.screen_name,
      author_link: user&.url,
      author_icon: user&.profile_image_url,
      text: message,
      color: '#cc2f2f'
    }]
  end
end
