# frozen_string_literal: true

class Api::Twitter::ApplicationController < Api::ApplicationController
  def index
    render json: '/api/twitter'
  end
end
