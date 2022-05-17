Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # resources :users
  post "/users", to: "users#create"
  get "/users/:id", to: "users#show"
  put "/users/:id", to: "users#update"
  post "/users/sign_in", to: "sessions#create"

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
end
