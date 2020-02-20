# frozen_string_literal: true

class Api::Twitter::UsersController < ApplicationController
  def index
    users = TwitterUser.all
    render json: users
  end

  def execute
    client = TwitterClient.new
    ids = client.fetch_follower_ids_of('tawachandesu')
    users = client.fetch_users(ids)
    render json: ids.to_json
    # render json: TwitterUser.find(1).followings
  end
end
