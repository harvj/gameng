Rails.application.routes.draw do
  root 'base#index'

  # --- Users / Devise

  devise_for :user
  devise_scope :user do
    get '/login'     => 'devise/sessions#new', as: :login
    delete '/logout' => 'devise/sessions#destroy', as: :logout
  end
end
