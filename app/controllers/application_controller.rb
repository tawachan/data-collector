# frozen_string_literal: true

require 'json'
require 'yaml'

class ApplicationController < ActionController::API
  def index
    render json: 'root'
  end

  def apidoc
    File.open(Rails.root.join('reference/api.v1.yaml')) do |yaml|
      object = YAML.safe_load(yaml, [], [], true)
      json = JSON.pretty_generate(object)
      render json: json
    end
  end
end
