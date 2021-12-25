Rails.application.routes.draw do
  # Handy override that prevents PUT routes from being created
  def put(*)
  end

  resources :activities do
    get :snapshots, on: :member
  end

  namespace :performance do
    resource :cycling do
      get :"power-curve", on: :collection
      get :"critical-power", on: :collection
    end
  end

  resource :session, controller: :session, only: %w[create update destroy]
  resources :users do
    get :activities, to: "activities#index", as: :activities
  end
  resource :user, controller: :authenticated_user, only: %w[show update] do
    resource :avatar, controller: :avatar, only: %w[show update]
  end
end
