# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/start')

  get '/health', to: proc { [200, {}, ['success']] }

  get '/start', to: 'pages#start'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
