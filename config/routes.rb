Rails.application.routes.draw do
  root 'base#index'

  # --- Users / Devise

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  devise_scope :user do
    get '/login'     => 'users/sessions#new', as: :login
    post 'login'     => 'users/sessions#create'
    delete '/logout' => 'users/sessions#destroy', as: :logout
  end
end
