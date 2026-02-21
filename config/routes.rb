Rails.application.routes.draw do
  admin_constraint = lambda do |request|
    session_id = request.cookie_jar.signed[:session_id]
    session = Session.find_by(id: session_id) if session_id
    session&.user&.is_admin?
  end

  mount MaintenanceTasks::Engine, at: "/maintenance_tasks", constraints: admin_constraint
  mount Avo::Engine, at: Avo.configuration.root_path, constraints: admin_constraint
  mount MissionControl::Jobs::Engine, at: "/jobs", constraints: admin_constraint

  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[new create]
  resources :users do
    member do
      get :settings
    end
  end
  get "email/confirm", to: "users/confirmations#show", as: :confirm_email
  get "email/re-confirm", to: "users/confirmations#resend_confirmation", as: :resend_confirmation
  get "/email-preview", to: "dev/email_preview#confirmation"
  get "/email-preview/reminder", to: "dev/email_preview#reminder"
  resources :feeds
  resources :articles do
    collection do
      get :search
    end
    member do
      patch :update_read
      patch :update_bookmark
    end
  end
  resources :bookmarks, only: %i[index]
  post "/subscribe", to: "subscriptions#create"
  post "/unsubscribe", to: "subscriptions#unsubscribe"
  get "/subscribe/thank-you", to: "subscriptions#thank_you"
  post "/lemonsqueezy/webhook", to: "lemonsqueezy#webhook"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
