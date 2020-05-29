module Representers
  class SessionCard < Representers::Base
    def build_object(session_card)
      deck = session_card.session_deck
      card = session_card.card
      {
        color: card.color,
        dealt: session_card.dealt?,
        dealtAt: session_card.dealt_at_micro,
        deckSlug: deck.slug,
        discarded: session_card.discarded?,
        discardedAt: session_card.discarded_at_micro,
        iconClass: card.icon_class,
        name: card.name.titleize,
        nameSort: card.name_sort,
        playable: session_card.playable?,
        played: session_card.played?,
        playedAt: session_card.played_at_micro,
        playerId: session_card.player_id,
        status: session_card.status.titleize,
        value: card.value.titleize,
        valueSort: card.value_sort
      }
    end
  end
end
