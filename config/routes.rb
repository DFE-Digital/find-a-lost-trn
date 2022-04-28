# frozen_string_literal: true

Rails.application.routes.draw do
  use_doorkeeper_openid_connect
  use_doorkeeper
  devise_for :users
  root to: redirect('/start')

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

  get '/name', to: 'name#edit'
  patch '/name', to: 'name#update'

  get '/date-of-birth', to: 'date_of_birth#edit'
  patch '/date-of-birth', to: 'date_of_birth#update'

  get '/have-ni-number', to: 'ni_number#new'
  patch '/have-ni-number', to: 'ni_number#create'
  post '/have-ni-number', to: 'ni_number#create'

  get '/ni-number', to: 'ni_number#edit'
  patch '/ni-number', to: 'ni_number#update'

  get '/awarded-qts', to: 'itt_providers#new'
  post '/awarded-qts', to: 'itt_providers#create'
  get '/itt-provider', to: 'itt_providers#edit'
  patch '/itt-provider', to: 'itt_providers#update'

  get '/email', to: 'email#edit'
  patch '/email', to: 'email#update'

  resource :trn_request, path: 'trn-request', only: %i[show update] do
    resource :email, controller: :email, only: %i[edit update]
  end

  get '/check-answers', to: 'trn_requests#show'

  get '/check-trn', to: 'check_trn#new'
  post '/check-trn', to: 'check_trn#create'

  get '/no-match', to: 'no_match#new'
  post '/no-match', to: 'no_match#create'

  get '/ask-questions', to: 'pages#ask_questions'
  get '/helpdesk-request-submitted', to: 'pages#helpdesk_request_submitted'
  get '/longer-than-normal', to: 'pages#longer_than_normal'
  get '/performance', to: 'pages#performance'
  get '/start', to: 'pages#start'
  get '/trn-found', to: 'pages#trn_found'
  get '/you-dont-have-a-trn', to: 'pages#you_dont_have_a_trn'

  get '/accessibility', to: 'static#accessibility'
  get '/cookies', to: 'static#cookies'
  get '/privacy', to: 'static#privacy'

  get '/health', to: proc { [200, {}, ['success']] }

  scope via: :all do
    get '/404', to: 'errors#not_found'
    get '/422', to: 'errors#unprocessable_entity'
    get '/500', to: 'errors#internal_server_error'
  end
end
