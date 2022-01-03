Rails.application.routes.draw do
  get 'users/index'
  get 'users/create'
  get 'users/show'
  get 'users/update'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :tasks
end
