# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'application#index'

  get 'apidoc', to: 'application#apidoc'

  namespace :api, format: 'json' do
    namespace :twitter do
      resources :jobs, only: %i[index create]
      get 'jobs/reset', to: 'jobs#reset'
    end

    resources :images, only: %i[index create]
  end

  mount Sidekiq::Web, at: '/sidekiq'
end
