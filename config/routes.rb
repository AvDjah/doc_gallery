Rails.application.routes.draw do
  resources :documents
  resources :categories
  resources :user

  controller :sessions do
    get "login" => :new, as: :login_path
    post "login" => :create
    delete "logout" => :destroy
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "/" => "home#index", as: :home_index
  get "/new_selected" => "categories#new_with_select", as: :new_with_select
  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # Defines the root path route ("/")
  # root "posts#index"
end
