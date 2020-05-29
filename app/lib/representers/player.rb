module Representers
  class Player < Representers::Base
    def build_object(player)
      scalar = {
        id: player.id,
        moderator: player.moderator?,
        user: Representers::User.(player.user)
      }
      return scalar if scalar_only?

      scalar.merge(
        cards: Representers::SessionCard.(player.cards)
      )
    end
  end
end
