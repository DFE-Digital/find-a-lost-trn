require "sidekiq/web"

Rails.application.routes.draw do
  root to: redirect("/start")

  devise_for :staff,
             controllers: {
               confirmations: "staff/confirmations",
               invitations: "staff/invitations",
               passwords: "staff/passwords",
               sessions: "staff/sessions",
               unlocks: "staff/unlocks"
             }

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

    resources :trn_requests, only: [] do
      resource :zendesk_sync, only: [:create], controller: "zendesk_sync"
    end

    devise_scope :staff do
      authenticate :staff do
        mount Sidekiq::Web, at: "sidekiq"
      end
    end
  end

  get "/name", to: "name#edit"
  post "/name", to: "name#update"

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

  # TODO: This should be a POST as it produces a side effect.
  get "/identity", to: "identity#create"

  get "/have-trn", to: "have_trn#new"
  post "/have-trn", to: "have_trn#create"

  get "/know-trn", to: "know_trn#new"
  post "/know-trn", to: "know_trn#create"

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

  scope via: :all do
    get "/404", to: "errors#not_found"
    get "/422", to: "errors#unprocessable_entity"
    get "/429", to: "errors#too_many_requests"
    get "/500", to: "errors#internal_server_error"
  end
end
