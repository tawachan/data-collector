# frozen_string_literal: true

class TestJob < ApplicationJob
  queue_as :default

  def perform(message)
    p "executed!!!#{message}"
  end
end
