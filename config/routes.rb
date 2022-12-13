require "sidekiq/web"

Rails.application.routes.draw do
  root to: redirect("/start")

  devise_for :staff,
             controllers: {
               confirmations: "staff/confirmations",
               invitations: "staff/invitations",
               omniauth_callbacks: "staff/omniauth_callbacks",
               passwords: "staff/passwords",
               sessions: "staff/sessions",
               unlocks: "staff/unlocks",
             }
  devise_scope :staff do
    get "/staff/sign_out", to: "staff/sessions#destroy"
  end

  namespace :support_interface, path: "/support" do
    get "/", to: redirect("/support/trn-requests")
    get "/trn-requests", to: "trn_requests#index"

    get "/features", to: "feature_flags#index"
    post "/features/:feature_name/activate",
         to: "feature_flags#activate",
         as: :activate_feature
    post "/features/:feature_name/deactivate",
         to: "feature_flags#deactivate",
         as: :deactivate_feature

    get "/validation-errors" => "validation_errors#index",
        :as => :validation_errors
    get "/validation-errors/:form_object" => "validation_errors#show",
        :as => :validation_error

    get "/zendesk", to: "zendesk#index"
    post "/zendesk/exports", to: "zendesk_csv_exports#create"
    get "/zendesk/confirm-deletion", to: "zendesk#confirm_deletion"
    post "/zendesk/confirm-deletion", to: "zendesk#destroy"
    get "/zendesk/performance", to: "zendesk_performance#index"

    resources :zendesk_imports, only: %i[new create]

    get "/identity", to: "users#index"
    post "/identity/confirm", to: "identity#confirm"
    get "/identity/simulate/callback", to: "identity#callback"
    get "/identity/simulate", to: "identity#new"

    resources :users,
              except: :destroy,
              path: "/identity/users",
              as: :identity_user
    get "/identity/users/:id/email", to: "users#email", as: :identity_user_email
    put "/identity/users/:id/email/update",
        to: "users#update_email",
        as: :update_identity_user_email

    resources :dqt_records, only: %i[edit update]

    resources :change_name,
              path: "/identity/change-name/",
              only: %i[show update]

    resources :trn_requests, only: [] do
      resource :zendesk_sync, only: [:create], controller: "zendesk_sync"
    end

    resources :staff, only: %i[index]

    devise_scope :staff do
      authenticate :staff do
        mount Sidekiq::Web, at: "sidekiq"
        mount Audits1984::Engine, at: "console"
      end
    end
  end

  get "/name", to: "name#edit"
  post "/name", to: "name#update"

  get "/preferred-name", to: "preferred_name#edit"
  post "/preferred-name", to: "preferred_name#update"

  get "/date-of-birth", to: "date_of_birth#edit"
  post "/date-of-birth", to: "date_of_birth#update"

  get "/have-ni-number", to: "has_ni_number#edit"
  post "/have-ni-number", to: "has_ni_number#update"

  get "/ni-number", to: "ni_number#edit"
  post "/ni-number", to: "ni_number#update"

  get "/awarded-qts", to: "awarded_qts#edit"
  post "/awarded-qts", to: "awarded_qts#update"

  get "/itt-provider", to: "itt_providers#edit"
  post "/itt-provider", to: "itt_providers#update"

  get "/email", to: "email#edit"
  post "/email", to: "email#update"

  resource :trn_request, path: "trn-request", only: %i[show update] do
    resource :email, controller: :email, only: %i[edit update]
  end

  get "/check-answers", to: "trn_requests#show"

  get "/check-trn", to: "check_trn#new"
  post "/check-trn", to: "check_trn#create"

  get "/no-match", to: "no_match#new"
  post "/no-match", to: "no_match#create"

  get "/ask-questions", to: "pages#ask_questions"
  get "/helpdesk-request-submitted", to: "pages#helpdesk_request_submitted"
  get "/helpdesk-request-delayed", to: "pages#helpdesk_request_delayed"
  get "/longer-than-normal", to: "pages#longer_than_normal"
  get "/start", to: "pages#start"
  get "/trn-found", to: "pages#trn_found"
  get "/you-dont-have-a-trn", to: "pages#you_dont_have_a_trn"

  get "/accessibility", to: "static#accessibility"
  get "/cookies", to: "static#cookies"
  get "/privacy", to: "static#privacy"

  get "/performance", to: "performance#index"

  post "/identity", to: "identity#create"

  get "/ask-trn", to: "ask_trn#new"
  post "/ask-trn", to: "ask_trn#create"

  scope via: :all do
    get "/404", to: "errors#not_found"
    get "/422", to: "errors#unprocessable_entity"
    get "/429", to: "errors#too_many_requests"
    get "/500", to: "errors#internal_server_error"
  end
end
