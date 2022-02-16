# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/start')

  resource :trn_request, only: %i[create show update]

  get '/check-answers', to: 'trn_requests#show'
  get '/health', to: proc { [200, {}, ['success']] }
  get '/helpdesk-request-submitted', to: 'pages#helpdesk_request_submitted'
  get '/start', to: 'pages#start'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
