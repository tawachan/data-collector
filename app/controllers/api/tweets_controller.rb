# frozen_string_literal: true

class Api::TweetsController < ApplicationController
  def index
    Tweet.all
  end

  def create
    Tweet.create(params)
  end
end
