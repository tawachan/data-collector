class Api::Twitter::UsersController < ApplicationController
  def index
    render json: "api/twitter/users"
  end
end
