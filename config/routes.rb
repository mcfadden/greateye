Rails.application.routes.draw do
  devise_for :users
  
  authenticate :user do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
    
  #resources :camera_event_assets
  resources :camera_events do
    collection do
      get '/kept' => 'camera_events#kept'
    end
    
    member do
      post 'keep' => 'camera_events#keep'
      post 'unkeep' => 'camera_events#unkeep'
    end
  end
  resources :cameras do
    collection do
      get :live
    end
  end
  

  root 'camera_events#index'

end
