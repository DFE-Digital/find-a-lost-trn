# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/start')

  resource :trn_request, path: 'trn-request', only: %i[show update] do
    resource :email, controller: :email, only: %i[edit update]
  end

  namespace :support_interface, path: '/support' do
    get '/', to: redirect('/support/trn-requests')
    get '/trn-requests', to: 'trn_requests#index'

    get '/features', to: 'feature_flags#index'
    post '/features/:feature_name/activate', to: 'feature_flags#activate', as: :activate_feature
    post '/features/:feature_name/deactivate', to: 'feature_flags#deactivate', as: :deactivate_feature

    # https://github.com/mperham/sidekiq/wiki/Monitoring#rails-http-basic-auth-from-routes
    require 'sidekiq/web'

    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(username),
        ::Digest::SHA256.hexdigest(ENV['SUPPORT_USERNAME']),
      ) &
        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(password),
          ::Digest::SHA256.hexdigest(ENV['SUPPORT_PASSWORD']),
        )
    end

    mount Sidekiq::Web, at: 'sidekiq'
  end

  get '/ask-questions', to: 'pages#ask_questions'
  get '/check-answers', to: 'trn_requests#show'
  get '/check-trn', to: 'check_trn#new'
  post '/check-trn', to: 'check_trn#create'
  get '/date-of-birth', to: 'date_of_birth#edit'
  patch '/date-of-birth', to: 'date_of_birth#update'
  get '/email', to: 'email#edit'
  patch '/email', to: 'email#update'
  get '/have-ni-number', to: 'ni_number#new'
  patch '/have-ni-number', to: 'ni_number#create'
  post '/have-ni-number', to: 'ni_number#create'
  get '/health', to: proc { [200, {}, ['success']] }
  get '/helpdesk-request-submitted', to: 'pages#helpdesk_request_submitted'
  get '/itt-provider', to: 'itt_providers#edit'
  patch '/itt-provider', to: 'itt_providers#update'
  get '/longer-than-normal', to: 'pages#longer_than_normal'
  get '/name', to: 'name#edit'
  patch '/name', to: 'name#update'
  get '/ni-number', to: 'ni_number#edit'
  patch '/ni-number', to: 'ni_number#update'
  get '/you-dont-have-a-trn', to: 'pages#you_dont_have_a_trn'
  get '/start', to: 'pages#start'
end
