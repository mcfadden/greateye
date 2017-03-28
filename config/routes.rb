Rails.application.routes.draw do
  devise_for :users

  authenticate :user, lambda { |u| u.admin? } do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  #resources :camera_event_assets
  resources :camera_events do
    collection do
      get '/kept' => 'camera_events#kept'
      get :selected_from_timeline
    end

    member do
      post 'keep' => 'camera_events#keep'
      post 'unkeep' => 'camera_events#unkeep'
    end
  end
  resources :cameras do
    member do
      get :preview
    end
    collection do
      get :live
    end
  end

  namespace :admin do
    resources :cameras do
      member do
        post :move_higher
        post :move_lower
      end
    end
    resources :users
    resources :system_settings, path: 'settings', only: [:index] do
      collection do
        patch :update
      end
    end
  end


  root 'cameras#live'

end
