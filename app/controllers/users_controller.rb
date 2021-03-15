class UsersController < ApplicationController
  before_action :load_user

  def show
    game = Game.find_by(key: 'modern_art')
    @user_stats = Representers::UserStats.(game)
  end

  private

  def load_user
    @user = User.find_by(username: params[:id]) || not_found
  end
end
