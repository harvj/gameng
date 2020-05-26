class GameSessionsController < BaseController
  def create
    play_class = "Play::#{params[:slug].classify}".safe_constantize
    session = play_class.().subject
    redirect_to game_session_path(session.uid)
  end

  def show
    session = GameSession.find_by(uid: params[:uid])
    @game_session = Representers::GameSession.(session)
    respond_to do |format|
      format.html
      format.json { render json: { status: 'success', content: { session: @game_session } } }
    end
  end
end
