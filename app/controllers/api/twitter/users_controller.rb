# frozen_string_literal: true

class Api::Twitter::UsersController < Api::ApplicationController
  def index
    users = TwitterUser.all
    render json: users
  end

  def execute
    screen_name = params[:screen_name]
    raise BadRequest, 'screen_name is not defined' if screen_name.nil?

    TwitterRegisterRelationshipsJob.perform_later(screen_name)
    render_success_response
  end
end
