class UsersController < ApplicationController
  def show
    game = Game.find_by(key: 'modern_art')
    @user_stats = Representers::UserStats.(game)
  end
end
