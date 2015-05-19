require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
    
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
  resources :cameras
  

  root 'camera_events#index'

end
