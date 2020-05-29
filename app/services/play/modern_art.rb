class Play::ModernArt < Play::Base

  MINIMUM_PLAYERS = 3
  MAXIMUM_PLAYERS = 5
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
  CARDS_TO_DEAL = {
    season_one:   { '3' => 10, '4' => 9, '5' => 8 },
    season_two:   { '3' => 6,  '4' => 4, '5' => 3 },
    season_three: { '3' => 6,  '4' => 4, '5' => 3 }
  }

  def initialize(_session=nil, _options={})
    super
    @draw_deck = session.decks.find_by(slug: 'draw')
  end

  attr_reader :draw_deck

  def next_action_text
    super.merge(
      season_one: 'Deal Season One',
      season_two: 'Deal Season Two',
      season_three: 'Deal Season Three'
    )
  end

  def started
    super
    build_deck(:draw)
  end

  def season_one
    draw_deck.deal_cards(session.players, CARDS_TO_DEAL[:season_one][session.players.count.to_s])
  end

  def season_two
    draw_deck.deal_cards(session.players, CARDS_TO_DEAL[:season_two][session.players.count.to_s])
  end

  def season_three
    draw_deck.deal_cards(session.players, CARDS_TO_DEAL[:season_three][session.players.count.to_s])
  end
end
