Rails.application.routes.draw do
  # Handy override that prevents PUT routes from being automatically created.
  alias put! put
  def put(*)
  end

  resources :activities, only: %w[create update show index destroy] do
    get :snapshots, on: :member
  end

  namespace :performance do
    resource :cycling do
      get :"power-curve", on: :collection
      get :"critical-power", on: :collection
      get :activities, on: :collection
    end
  end

  resource :session, controller: :session, only: %w[create update destroy]
  resources :users do
    get :activities, on: :member
    put! :friend, on: :member, to: "users#add_friend"
    delete :friend, on: :member, to: "users#remove_friend"
  end
  resource :user, controller: :authenticated_user, only: %w[show update] do
    resource :avatar, controller: :avatar, only: %w[show update]
    get :activities, on: :member
    get :friends, on: :member
    get :"friend-requests", on: :member
  end
  resources :friendships, only: :index
end
