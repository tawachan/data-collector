Rails.application.routes.draw do
  root to: 'applications#index'

  namespace :api do
    namespace :twitter do
      resources :users
    end
  end
end
