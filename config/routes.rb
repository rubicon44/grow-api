Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :v1 do
    resources :tasks do
      resources :likes, only: [:index, :create, :destroy]
    end

    resources :users, only: [:show] do
      resource :relationships, only: [:create, :destroy]
    end

    resources :notifications, only: [:index]
    resources :searches, only: [:index]

    post "/users", to: "users#create"
    get "/:username", to: "users#show"
    put "/:username", to: "users#update"
    get '/:username/followings', to: 'users#followings'
    get "/:username/followers", to: "users#followers"
    post "/users/sign_in", to: "sessions#create"
  end
end