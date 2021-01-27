module Representers
  class Player < Representers::Base
    def build_object(player)
      return nil if player.nil?

      scalar = {
        id: player.id,
        actionPhase: player.action_phase,
        actionPrompt: player.action_prompt,
        moderator: player.moderator?,
        role: Representers::Role.(player.role),
        score: player.score,
        turnOrder: player.turn_order,
        user: Representers::User.(player.user),
        winner: player.winner,
        playPath: play_player_path(player),
        playerPath: player_path(player)
      }
      return scalar if scalar_only?

      scalar.merge(
        activeCards: Representers::SessionCard.(player.cards.active),
        inactiveCards: Representers::SessionCard.(player.cards.inactive),
        playHistory: Representers::SessionFrame.(player.frames.card_played),
        possibleActions: player.possible_actions,
      )
    end
  end
end
