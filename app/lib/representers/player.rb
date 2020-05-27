module Representers
  class Player < Representers::Base
    def build_object(player)
      @player = player
      @session = options[:session]

      result = {
        user: Representers::User.(player.user)
      }

      result.merge!(session_info) if session.present?

      result
    end

    attr_reader :player, :session

    private

    def session_deck
      session.decks.first
    end

    def session_cards
      return [] unless session_deck.present?
      session_deck.cards.where(player_id: player.id).map do |session_card|
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

    def session_info
      {
        cards: session_cards
      }
    end
  end
end
