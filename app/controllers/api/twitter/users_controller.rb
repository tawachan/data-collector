# frozen_string_literal: true

class Api::Twitter::UsersController < ApplicationController
  def index
    hoge = TestJob.perform_later('message')
    render json: hoge
  end
end
