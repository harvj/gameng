class Play::ModernArt < Play::Base
  SEQUENCE = [
    :started,
    :season_one,
    :season_two,
    :season_three
  ].freeze

  DRAW_DECK = {
    lite_metal: {
      once_around: 3,
      fixed_price: 2,
      sealed: 2,
      open: 3,
      double: 2
    },
    yoko: {
      once_around: 2,
      fixed_price: 3,
      sealed: 3,
      open: 3,
      double: 2
    },
    cristin_p: {
      once_around: 3,
      fixed_price: 3,
      sealed: 3,
      open: 3,
      double: 2
    },
    karl_gitter: {
      once_around: 3,
      fixed_price: 3,
      sealed: 3,
      open: 3,
      double: 3
    },
    krypto: {
      once_around: 3,
      fixed_price: 3,
      sealed: 3,
      open: 4,
      double: 3
    }
  }

  def season_one
    draw_deck.deal_cards(session.users, 8)
  end

  def draw_deck
    @draw_deck ||= session.decks.find_by(slug: 'draw') || build_draw_deck
  end

  def build_draw_deck
    deck = session.decks.create(slug: 'draw')
    DRAW_DECK.each do |artist, auction_types|
      auction_types.each do |auction_type, count|
        count.times do |i|
          params = {name: artist, value: auction_type}
          card = game.cards.find_by(params)
          log("building SessionCard: #{params}")
          deck.cards.create(card_id: card.id)
        end
      end
    end
    deck
  end
end
