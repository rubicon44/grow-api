Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :tasks do
    # resources :comments, only: [:create, :destroy]
    resources :likes, only: [:index, :create, :destroy]
  end

  resources :users, only: [:show] do
    resource :relationships, only: [:create, :destroy]
    get :followings, on: :member
    get :followers, on: :member
  end

  resources :notifications, only: [:index]
  resources :searches, only: [:index]

  # resources :users
  post "/users", to: "users#create"
  get "/:username", to: "users#show"
  put "/:username", to: "users#update"
  post "/users/sign_in", to: "sessions#create"
end
