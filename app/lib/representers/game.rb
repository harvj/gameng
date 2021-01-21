module Representers
  class Game < Representers::Base
    def build_object(game)
      scalar = {
        name: game.name,
        key: game.key,
        uri: game_path(game.key),
        groupCardsBy: game.play_class::CONFIG[:groupCardsBy],
        sortCardsBy: game.play_class::CONFIG[:sortCardsBy]
      }
      return scalar if scalar_only?

      scalar.merge(
        sessions: Representers::GameSession.(game.sessions, scalar: true)
      )
    end
  end
end
