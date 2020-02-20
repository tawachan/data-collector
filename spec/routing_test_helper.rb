# frozen_string_literal: true

require 'rails_helper'

module RoutingTestHelper
  def routes(namespace: nil, actions: nil, ignore_paths: [])
    filtered_routes = all_routes
    filtered_routes.select! { |route| route.name.include?(namespace) }    if namespace
    filtered_routes.select! { |route| actions.include?(route.action) }    if actions
    filtered_routes.select! { |route| ignore_paths.exclude?(route.name) } if ignore_paths
    filtered_routes.reject { |route| route.url.nil? }
  end

  private

  def rails_routes
    Rails.application.routes
  end

  def all_routes
    rails_routes.routes.select(&:name).map do |route|
      Route.new(route, rails_routes.url_helpers)
    end
  end

  class Route
    def initialize(route, url_helpers)
      @name = route.name
      @action = route.requirements[:action]
      @controller = route.defaults[:controller]
      @keys = route.path.required_names
      @url_helpers = url_helpers
    end

    attr_reader :name, :action, :controller, :keys, :url_helpers

    def attributes
      attributes = { host: 'localhost', controller: controller, action: action }
      # NOTE: must be created record with key before execution.
      attributes.tap { keys.each { |key| attributes.merge!(key.to_sym => 1) } }
    end

    def url
      url_helpers.url_for attributes
    rescue ActionController::UrlGenerationError
      nil
    end
  end
end
