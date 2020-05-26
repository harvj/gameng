class Play::ModernArt < Play::Base

  MINIMUM_PLAYERS = 3
  PLAY_SEQUENCE = %i(season_one season_two season_three).freeze
  DECKS = {
    draw: {
      lite_metal: {
        once_around: 3, fixed: 2, sealed: 2, open: 3, double: 2
      },
      yoko: {
        once_around: 2, fixed: 3, sealed: 3, open: 3, double: 2
      },
      cristin_p: {
        once_around: 3, fixed: 3, sealed: 3, open: 3, double: 2
      },
      karl_gitter: {
        once_around: 3, fixed: 3, sealed: 3, open: 3, double: 3
      },
      krypto: {
        once_around: 3, fixed: 3, sealed: 3, open: 4, double: 3
      }
    }
  }

  def initialize(_session=nil)
    super
    @draw_deck = session.decks.find_by(slug: 'draw')
  end

  attr_reader :draw_deck

  def started
    super
    build_deck(:draw)
  end

  def season_one
    draw_deck.deal_cards(session.players, 8)
  end
end
