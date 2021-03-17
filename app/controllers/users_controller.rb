class UsersController < ApplicationController
  before_action :load_user

  def show
    game = Game.find_by(key: 'modern_art')
    @user_stats = Query::Players.(:user_stats, game_id: game.id).group_by(&:player_count)
    @score_stats = Query::Players.(:score_stats, game_id: game.id)
  end

  private

  def load_user
    @user = User.find_by(username: params[:id]) || not_found
  end
end
