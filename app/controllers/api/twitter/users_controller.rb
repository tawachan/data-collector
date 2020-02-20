# frozen_string_literal: true

class Api::Twitter::UsersController < ApplicationController
  def index
    hoge = TestJob.perform_later('something like this')
    render json: hoge
  end
end
