# frozen_string_literal: true

class Api::Twitter::JobsController < Api::ApplicationController
  def index
    render json: { queues: Sidekiq::Queue.new }
  end

  def create
    screen_name = params[:screen_name]
    raise BadRequest, 'screen_name is not defined' if screen_name.nil?

    TwitterRegisterRelationshipsJob.perform_later(screen_name)

    render_success_response
  end

  def reset
    Sidekiq::ScheduledSet.new.clear
    render_success_response('delete all the queued jobs')
  end
end
