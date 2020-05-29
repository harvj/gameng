class PlayersController < ApplicationController
  def create
    @game_session = GameSession.find_by(uid: params[:uid])
    Player::Create.!(current_user, game_session: @game_session)
    render json: { status: 'success', content: { session: Representers::GameSession.(@game_session.reload) } }
  end
end
