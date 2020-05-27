module Representers
  class Game < Representers::Base
    def build_object(game)
      @game = game

      scalar = {
        name: game.name,
        slug: game.slug,
        showPath: game_path(game.slug)
      }
      return scalar if scalar_only?

      scalar.merge(
        sessions: sessions
      )
    end

    attr_reader :game

    def sessions
      game.sessions.map do |session|
        {
          state: session.state.titleize,
          uid: session.uid,
          started: session.started?,
          uri: game_session_path(session.uid)
        }
      end
    end
  end
end
