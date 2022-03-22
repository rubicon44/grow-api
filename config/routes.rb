Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :tasks
  resources :users
  post "/users", to: "users#create"
  get "/users/:id", to: "users#show"
  put "/users/:id", to: "users#update"
  post "/users/sign_in", to: "sessions#create"
end
