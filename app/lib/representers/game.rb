module Representers
  class Game < Representers::Base
    def build_object(game)
      scalar = {
        name: game.name,
        slug: game.slug,
        uri: game_path(game.slug)
      }
      return scalar if scalar_only?

      scalar.merge(
        sessions: Representers::GameSession.(game.sessions, scalar: true)
      )
    end
  end
end
