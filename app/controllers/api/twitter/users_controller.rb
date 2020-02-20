# frozen_string_literal: true

class Api::Twitter::UsersController < ApplicationController
  def index
    TestJob.perform_later('message')
    render json: {}
  end
end
