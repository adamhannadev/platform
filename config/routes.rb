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
  root "teachers#index"

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

  resources :students
  get "students/:id/:dance" => "students#charts", as: :charts
  
  resources :lessons

  # Update the charts when clicked on students chart.
  patch 'charts/:id/toggle', to: 'charts#toggle'

  resources :availabilities
  # post 'availabilities/bulk_create_teacher', to: 'availabilities#bulk_create_teacher', as: :bulk_create_teacher_availabilities
  get "availabilities/month/:month" => "availabilities#index", as: :availabilities_month

  resources :figures

end
