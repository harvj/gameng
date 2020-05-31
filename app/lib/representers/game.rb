module Representers
  class Game < Representers::Base
    def build_object(game)
      scalar = {
        name: game.name,
        key: game.key,
        uri: game_path(game.key)
      }
      return scalar if scalar_only?

      scalar.merge(
        sessions: Representers::GameSession.(game.sessions, scalar: true)
      )
    end
  end
end
