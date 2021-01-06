class SessionCardsController < ApplicationController
  before_action :load_session_card, only: %i(discard play retrieve)

  def discard
  end

  def play
    @session_card.play
    @rep_session = Representers::GameSession.(@session_card.session, user: current_user)
    render json: { status: 'success', content: { session: @rep_session }, errors: [] }
  end

  def retrieve
  end

  private

  def load_session_card
    @session_card = SessionCard.find(params[:id])
  end
end
