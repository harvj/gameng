Rails.application.routes.draw do
  root 'games#index'

  resources :game_sessions, only: %i(create)

  resources :players, only: %i(create update) do
    member do
      patch :play
    end
  end

  resources :session_cards, only: %i(update) do
  end

  resources :users, only: %i(show) do
    resource :user_config, only: %i(update), as: :config, path: :config
  end

  devise_for :users, controllers: { sessions: 'users/sessions' }

  devise_scope :user do
    get '/login'     => 'users/sessions#new', as: :login
    post 'login'     => 'users/sessions#create'
    delete '/logout' => 'users/sessions#destroy', as: :logout
  end

  get 'sessions/:uid' => 'game_sessions#show', as: :game_session
  patch 'sessions/:uid' => 'game_sessions#update'
  delete 'sessions/:uid' => 'game_sessions#destroy'

  get ':game_key' => 'games#show', as: :game
end
