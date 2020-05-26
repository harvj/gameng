module Representers
  class GameSession < Representers::Base
    attr_reader :session

    def build_object(session)
      @session = session
      {
        game: Representers::Game.(session.game, scalar: true),
        uid: session.uid,
        state: session.state,
        started_at: session.started_at&.strftime('%a %e %b, %Y %k:%M:%S'),
        ended_at: session.ended_at,
        players: players,
        decks: decks
      }
    end

    def players
      session.players.map do |player|
        {
          name: player.user.name,
          cards: player_cards(player)
        }
      end
    end

    def decks
      session.decks.map do |deck|
        {
          slug: deck.slug,
          card_count: deck.cards.count
        }
      end
    end

    def player_cards(player)
      deck = session.decks.first
      deck.cards.where(player_id: player.id).map do |session_card|
        card = session_card.card
        {
          name: card.name.titleize,
          value: card.value,
          color: card.color,
          iconClass: card.icon_class,
          sort: card.game_logical_sort
        }
      end
    end
  end
end
