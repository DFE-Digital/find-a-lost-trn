# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/start')

  resource :trn_request, only: %i[show update] do
    resource :email, controller: :email, only: %i[edit update]
  end

  namespace :support_interface, path: '/support' do
    get '/', to: redirect('/support/trn-requests')
    get '/trn-requests', to: 'trn_requests#index'
  end

  get '/check-answers', to: 'trn_requests#show'
  get '/email', to: 'email#edit'
  patch '/email', to: 'email#update'
  get '/health', to: proc { [200, {}, ['success']] }
  get '/helpdesk-request-submitted', to: 'pages#helpdesk_request_submitted'
  get '/itt-provider', to: 'itt_providers#edit'
  patch '/itt-provider', to: 'itt_providers#update'
  get '/start', to: 'pages#start'
end
