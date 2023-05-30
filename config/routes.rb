# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :v1 do
    resources :tasks do
      resources :likes, only: %i[index create destroy]
    end

    resources :users, only: %i[index create] do
      resource :relationships, only: %i[create destroy]
    end

    resources :notifications, only: [:index]
    resources :searches, only: [:index]

    get '/csrf_token', to: 'csrf_tokens#new'
    get '/:username', to: 'users#show'
    put '/:username', to: 'users#update'
    get '/:username/followings', to: 'users#followings'
    get '/:username/followers', to: 'users#followers'
    post '/users/sign_in', to: 'sessions#create'
  end
end
