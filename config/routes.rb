# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/start')

  resource :trn_request, only: %i[show update] do
    resource :email, controller: :email, only: %i[edit update]
  end

  get '/check-answers', to: 'trn_requests#show'
  get '/email', to: 'email#edit'
  patch '/email', to: 'email#update'
  get '/health', to: proc { [200, {}, ['success']] }
  get '/helpdesk-request-submitted', to: 'pages#helpdesk_request_submitted'
  get '/start', to: 'pages#start'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
