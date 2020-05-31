class Play::ModernArt < Play::Base
  PLAY_SEQUENCE = %w(season_one season_two season_three).freeze
  DECKS = {
    default: {
      lite_metal:  { once_around: 3, fixed: 2, sealed: 2, open: 3, double: 2 },
      yoko:        { once_around: 2, fixed: 3, sealed: 3, open: 3, double: 2 },
      cristin_p:   { once_around: 3, fixed: 3, sealed: 3, open: 3, double: 2 },
      karl_gitter: { once_around: 3, fixed: 3, sealed: 3, open: 3, double: 3 },
      krypto:      { once_around: 3, fixed: 3, sealed: 3, open: 4, double: 3 }
    }
  }
  CARDS_TO_DEAL = {
    season_one:   { '3' => 10, '4' => 9, '5' => 8 },
    season_two:   { '3' => 6,  '4' => 4, '5' => 3 },
    season_three: { '3' => 6,  '4' => 4, '5' => 3 }
  }
  TERMS = {
    name: 'artist',
    nameSort: 'artist',
    value: 'auction type',
    valueSort: 'auction type',
    dealtDuringState: 'season dealt',
    status: 'hand'
  }

  def deck
    @deck ||= session.decks.find_by(key: 'default')
  end

  def season_one
    deck.deal_cards(session.players, CARDS_TO_DEAL[:season_one][session.players.count.to_s])
  end

  def season_two
    deck.deal_cards(session.players, CARDS_TO_DEAL[:season_two][session.players.count.to_s])
  end

  def season_three
    deck.deal_cards(session.players, CARDS_TO_DEAL[:season_three][session.players.count.to_s])
  end
end
