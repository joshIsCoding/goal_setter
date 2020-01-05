Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users, only: [:create, :new, :show] do
    resources :goals, only: [:index, :new]
  end
  resource :session, only: [:create, :new, :destroy]
  resources :goals, only: [:create, :edit, :update, :destroy]

end
