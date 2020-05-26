class GamesController < BaseController
  def index
    @games = Representers::Game.(Game.all)
    respond_to do |format|
      format.html
      format.json { render json: { status: 'success', content: { games: @games }}.to_json }
    end
  end

  def show
    @game = Representers::Game.(Game.find_by(slug: params[:slug]))
    respond_to do |format|
      format.html
      format.json { render json: { status: 'success', content: { game: @game }}.to_json }
    end
  end
end
