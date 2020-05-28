class GameSessionsController < ApplicationController
  before_action :load_game_session, only: %i(update show destroy)

  def create
    play_class = "Play::#{params[:slug].classify}".safe_constantize
    game_session = play_class.().subject
    redirect_to game_session_path(game_session.uid)
  end

  def update
    play_class = "Play::#{@game_session.game.slug.classify}".safe_constantize
    updated_session = play_class.(@game_session).subject
    @rep_session = Representers::GameSession.(updated_session)
    render json: { status: 'success', content: { session: @rep_session } }
  end

  def show
    @rep_session = Representers::GameSession.(@game_session)
    respond_to do |format|
      format.html
      format.json { render json: { status: 'success', content: { session: @rep_session } } }
    end
  end

  def destroy
    game_slug = @game_session.game.slug
    @game_session.destroy
    redirect_to game_path(game_slug)
  end

  private

  def load_game_session
    @game_session = GameSession.find_by(uid: params[:uid]) || not_found
  end
end
