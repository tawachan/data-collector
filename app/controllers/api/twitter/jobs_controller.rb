# frozen_string_literal: true

class Api::Twitter::JobsController < Api::ApplicationController
  def index
    queue_count = Sidekiq::Queue.new.size
    user_count = TwitterUser.all.count
    relationship_count = TwitterRelationship.all.count
    render json: { queues: queue_count, user: user_count, relationship: relationship_count }
  end

  def create
    screen_name = params[:screen_name]
    layer_count = params[:layer_count] || 1
    with_user_detail = params[:with_user_detail] || false
    raise BadRequest, 'screen_name is not defined' if screen_name.nil?

    if with_user_detail
      TwitterRegisterRelationshipsWithUserDataJob.perform_later(screen_name, layer_count)
    else
      TwitterRegisterRelationshipsDataJob.perform_later(screen_name, layer_count)
    end
    render_success_response
  end

  def reset
    Sidekiq::ScheduledSet.new.clear
    render_success_response('delete all the queued jobs')
  end
end
