Rails.application.routes.draw do
  resources :activities do
    get :snapshots, on: :member
  end

  namespace :performance do
    resource :cycling do
      get :"power-curve", on: :collection
      get :"critical-power", on: :collection
    end
  end
end
