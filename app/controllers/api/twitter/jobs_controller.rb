# frozen_string_literal: true

class Api::Twitter::JobsController < Api::ApplicationController
  def index
    render json: { queues: Sidekiq::Queue.new }
  end

  def create
    screen_name = params[:screen_name]
    layer_count = params[:layer_count] || 1
    raise BadRequest, 'screen_name is not defined' if screen_name.nil?

    TwitterRegisterRelationshipsJob.perform_later(screen_name, layer_count)

    render_success_response
  end

  def reset
    Sidekiq::ScheduledSet.new.clear
    render_success_response('delete all the queued jobs')
  end
end
