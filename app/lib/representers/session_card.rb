module Representers
  class SessionCard < Representers::Base
    def build_object(session_card)
      @session_card = session_card
      deck = session_card.session_deck
      card = session_card.card
      {
        color: card.color,
        dealt: session_card.dealt?,
        dealtAt: session_card.dealt_at_milli,
        dealtDuringState: dealt_during_state,
        deckKey: deck.key,
        discarded: session_card.discarded?,
        discardedAt: session_card.discarded_at_milli,
        iconClass: card.icon_class,
        id: session_card.id,
        name: card.name.titleize,
        nameSort: card.name_sort,
        playable: session_card.playable?,
        playCardPath: play_session_card_path(session_card),
        played: session_card.played?,
        playedAt: session_card.played_at_milli,
        playerId: session_card.player_id,
        status: session_card.status.titleize,
        value: card.value.titleize,
        valueSort: card.value_sort
      }
    end

    attr_reader :session_card

    def dealt_during_state
      return unless session_card.dealt?
      "Dealt #{session_card.dealt_during_state.titleize}"
    end
  end
end