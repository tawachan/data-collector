# frozen_string_literal: true

class Api::ImagesController < Api::ApplicationController
  def index
    render json: []
  end

  def create
    image = Image.create(image: params[:image])
    render json: image.image.metadata.to_json, url: rails_representation_url(
      image.image.variant(resize: '1024', strip: true).processed, disposition: :inline
    )
  end

  def create_params
    params.methods
  end
end
