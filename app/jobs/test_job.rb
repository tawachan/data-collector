# frozen_string_literal: true

class TestJob < ApplicationJob
  queue_as :low

  def perform(message)
    TwitterUser.create(screen_name: 'ほげ', unique_id: message)
  end
end
