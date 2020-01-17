Rails.application.routes.draw do
  get 'welcome/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users, only: [:create, :new, :show, :index] do
    resources :goals, only: [:new]
  end
  resource :session, only: [:create, :new, :destroy]
  resources :goals, only: [:show, :create, :edit, :update, :destroy]
  resources :comments, only: [:create, :destroy]
  resources :up_votes, only: [:create, :destroy]

  root 'welcome#index'
end
