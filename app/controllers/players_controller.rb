class PlayersController < ApplicationController
  before_action :load_game_session, only: %i(create)

  def create
    player_create = Player::Create.(current_user, game_session: @game_session)
    render json: {
      status: player_create.status,
      content: { session: Representers::GameSession.(@game_session.reload) },
      errors: player_create.errors
    }
  end

  private

  def load_game_session
    @game_session = GameSession.find_by(uid: params[:uid])
  end
end
