Rails.application.routes.draw do
  root 'games#index'

  resources :games, only: %i(index)
  resources :game_sessions, only: %i(create)

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  devise_scope :user do
    get '/login'     => 'users/sessions#new', as: :login
    post 'login'     => 'users/sessions#create'
    delete '/logout' => 'users/sessions#destroy', as: :logout
  end

  get 'sessions/:uid' => 'game_sessions#show', as: :game_session

  get ':slug' => 'games#show', as: :game
end
