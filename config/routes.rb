# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/start')

  resources :trn_requests, only: [:create]

  get '/health', to: proc { [200, {}, ['success']] }
  get '/helpdesk-request-submitted', to: 'pages#helpdesk_request_submitted'
  get '/start', to: 'pages#start'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
