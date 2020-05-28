class PlayersController < ApplicationController
  def create
    @game_session = GameSession.find_by(uid: params[:uid])
    @game_session.players.create(user_id: current_user.id)
    render json: { status: 'success', content: { session: Representers::GameSession.(@game_session.reload) } }
  end
end
