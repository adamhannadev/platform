Rails.application.routes.draw do

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root to: "pages#login"
  get "test_message", to: "pages#test_message"

  resources :teachers do
      get 'schedule', on: :member
        resources :availabilities, only: [:index, :new, :create] do
      get 'month/:month', on: :collection, action: :index, as: :month
    end
  end

    resources :locations do
    resources :availabilities, only: [:index, :new, :create] do
      get 'month/:month', on: :collection, action: :index, as: :month
    end
  end

  resources :lessons

  # Update the charts when clicked on students chart.
  patch 'charts/:id/toggle', to: 'charts#toggle'

  # Admin routes - only accessible to admin users
  namespace :admin do
    root 'dashboard#index'
    resources :users
    
    resources :students do
      member do
        get :charts
      end
    end
    
    resources :teachers do
      resources :availabilities
      member do
        get :schedules
      end
    end
    
    resources :locations do
      resources :availabilities
      member do
        get :schedules
      end
    end
    
    resources :availabilities, only: [:show, :edit, :update, :destroy]
    resources :figures
  end

  resources :booking, only: [:index, :new, :create] do
    collection do
      get :available_days
      get :available_teachers
      get :available_timeslots
    end
  end

end
