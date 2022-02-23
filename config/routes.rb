# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/start')

  resource :trn_request, only: %i[show update] do
    resource :email, controller: :email, only: %i[edit update]
  end

  get '/check-answers', to: 'trn_requests#show'
  get '/email', to: 'email#edit'
  patch '/email', to: 'email#update'
  get '/have-ni-number', to: 'ni_number#new'
  post '/have-ni-number', to: 'ni_number#create'
  get '/health', to: proc { [200, {}, ['success']] }
  get '/helpdesk-request-submitted', to: 'pages#helpdesk_request_submitted'
  get '/itt-provider', to: 'itt_providers#edit'
  patch '/itt-provider', to: 'itt_providers#update'
  get '/ni-number', to: 'ni_number#edit'
  patch '/ni-number', to: 'ni_number#update'
  get '/start', to: 'pages#start'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
