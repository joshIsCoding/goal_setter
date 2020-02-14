Rails.application.routes.draw do
  root 'welcome#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users, only: [:create, :show, :index] do
    resources :goals, only: [:new]
    resources :sessions, only: [:index]
    resources :notifications, only: [:index]
  end
  get "register", to: "users#new"
  get "login", to: "sessions#new"

  resources :sessions, only: [:create, :destroy]
  resources :goals, only: [:show, :index, :create, :edit, :update, :destroy]
  resources :comments, only: [:create, :destroy]
  resources :up_votes, only: [:create, :destroy]
  resources :notifications, only: [:update]  
end
