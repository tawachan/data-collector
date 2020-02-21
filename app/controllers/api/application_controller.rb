# frozen_string_literal: true

class Api::ApplicationController < ApplicationController
  class BadRequest < StandardError; end
  class Unauthorized < StandardError; end
  class NotFound < StandardError; end
  class InternalServerError < StandardError; end

  rescue_from StandardError, with: :render_internal_server_error

  rescue_from BadRequest, with: :render_bad_request
  rescue_from Unauthorized, with: :render_unauthorized
  rescue_from NotFound, with: :render_not_found
  rescue_from InternalServerError, with: :render_internal_server_error

  # 200 ok
  def render_success_response(message = 'success')
    render status: :ok, json: { status: 200, message: message }
  end

  # 400 Bad Request
  def render_bad_request(error = nil)
    logger.error(error.full_message)
    render status: :bad_request, json: { status: 400, message: error.message }
  end

  # 401 Unauthorized
  def render_unauthorized(error = nil)
    logger.error(error.full_message)
    render status: :unauthorized, json: { status: 401, message: error.message }
  end

  # 404 Not Found
  def render_not_found(error = nil)
    logger.error(error.full_message)
    render status: :not_found, json: { status: 404, message: error.message }
  end

  # 500 Internal Server Error
  def render_internal_server_error(error = nil)
    logger.error(error.full_message)
    render status: :internal_server_error, json: { status: 500, message: error.message }
  end
end
