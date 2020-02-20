# frozen_string_literal: true

class Api::Twitter::UsersController < Api::ApplicationController
  def index
    render json: 'api/twitter/users'
  end
end
