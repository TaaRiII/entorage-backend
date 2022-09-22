Rails.application.routes.draw do

  # devise_for :users
  # api
  mount API => '/'
  #root url
  # api docs frontend
  mount GrapeSwaggerRails::Engine => '/docs'

  # home page
  root 'home#index'

  devise_for :admins
  authenticate :admin do
    namespace :admin do
      require 'sidekiq/web'
      require 'sidekiq/cron/web'
      mount Sidekiq::Web, at: '/jobs'

      root 'users#index', as: :root
      resources :users do
        member do
          get :toggle_block
          get :award
        end
        collection do
          get :active
          get  :setting
          post :save_setting
        end
      end
      resources :group_statuses do
        member do
          post "set_position"
        end
      end
      resources :devices
      resources :notifications
      resources :reports do
        member do
          put :change_status
        end
      end
    end
  end

end
