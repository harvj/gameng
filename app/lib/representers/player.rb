module Representers
  class Player < Representers::Base
    def build_object(player)
      return nil if player.nil?

      scalar = {
        id: player.id,
        actionable: player.actionable?,
        actionPhase: player.action_phase,
        actionPrompt: player.action_prompt,
        activeCardCount: player.active_card_count,
        moderator: player.moderator?,
        possibleActions: player.possible_actions,
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
        cards: Representers::SessionCard.(player.cards),
        playHistory: Representers::SessionFrame.(player.frames.card_played)
      )
    end
  end
end
