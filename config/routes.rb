Rails.application.routes.draw do
  root 'games#index'

  resources :games, only: %i(index)
  resources :game_sessions, only: %i(create)
  resources :players, only: %i(create)

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  devise_scope :user do
    get '/login'     => 'users/sessions#new', as: :login
    post 'login'     => 'users/sessions#create'
    delete '/logout' => 'users/sessions#destroy', as: :logout
  end

  get 'sessions/:uid' => 'game_sessions#show', as: :game_session
  patch 'sessions/:uid' => 'game_sessions#update'
  delete 'sessions/:uid' => 'game_sessions#destroy'

  get ':slug' => 'games#show', as: :game
end
