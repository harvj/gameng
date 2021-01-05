module Representers
  class Player < Representers::Base
    def build_object(player)
      scalar = {
        id: player.id,
        canPass: player.can_pass?,
        moderator: player.moderator?,
        score: player.score,
        turnOrder: player.turn_order,
        user: Representers::User.(player.user),
        winner: player.winner,
        passPath: pass_player_path(player),
        playerPath: player_path(player)
      }
      return scalar if scalar_only?

      scalar.merge(
        cards: Representers::SessionCard.(player.cards),
        playHistory: Representers::SessionFrame.(player.frames.card_played)
      )
    end
  end
end
