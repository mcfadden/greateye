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
      get :live_focus
      put :live_focus, action: 'update_live_focus'
    end
  end

  resource :cron, controller: 'cron' do
    post :mark_events_as_failed
    post :clean_tempfiles
    post :purge_old_events
    post :find_new_motion_events
    post :perform_remote_cleanup
  end

  namespace :admin do
    resources :cameras do
      member do
        post :move_higher
        post :move_lower
      end
      resource :stats, controller: 'cameras/stats'
    end
    resources :users
    resources :system_settings, path: 'settings', only: [:index] do
      collection do
        patch :update
        post :reboot
      end
    end
    resources :stats
  end


  root 'cameras#live'

end
