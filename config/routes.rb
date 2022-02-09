# frozen_string_literal: true
Rails.application.routes.draw do
  root to: 'pages#home'

  get 'find-lost-trn/:page', to: 'find_lost_trn#edit', as: :teacher_edit
  patch 'find-lost-trn/:page', to: 'find_lost_trn#update', as: :teacher_update
end
