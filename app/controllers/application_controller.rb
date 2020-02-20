class ApplicationController < ActionController::API
  def index
    render json: "root"
  end
end
