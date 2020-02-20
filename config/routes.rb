# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'application#index'

  get 'apidoc', to: 'application#apidoc'

  namespace :api do
    namespace :twitter do
      resources :users, only: [:index]
      post '/users/execute', to: 'users#execute'
    end
  end

  mount Sidekiq::Web, at: '/sidekiq'
end
