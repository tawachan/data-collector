# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'application#index'

  namespace :api do
    namespace :twitter do
      resources :users, only: [:index]
    end
  end
end
