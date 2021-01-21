class Play::Pandemic < Play::Base
  PLAY_SEQUENCE = [].freeze

  EPIDEMIC_COUNT = 5

  TERMS = {
    name: 'name',
    nameSort: 'name',
    value: 'strain',
    valueSort: 'strain',
    dealtDuringState: 'dealt',
    status: 'status'
  }

  CONFIG = {
    groupCardsBy: 'value',
    sortCardsBy: 'status'
  }

  attr_accessor :init_draw_pile, :draw_deck

  def player_count
    players.count
  end

  def initial_deal_count
    { '2' => 4, '3' => 3, '4' => 2 }
  end

  def infection_count
    { '0' => 2, '1' => 2, '2' => 2, '3' => 3, '4' => 3, '5' => 4, '6' => 4 }
  end

  def build_card_decks
    create_infection_decks
    deal_initial_cards
    create_draw_decks
  end

  def create_infection_decks
    infection = decks.create(key: 'infection')
    infection_discard = decks.create(key: 'infection-discard')
    game.cards.where(key: 'infection').each do |card|
      SessionCard::Create.!(infection, card: card)
    end
    infection.cards.shuffle.first(9).each do |card|
      card.update_attributes(
        session_deck: infection_discard,
        discarded_at: Time.zone.now
      )
    end
  end

  def init_draw_pile
    @init_draw_pile ||= game.cards.where(key: 'player').shuffle
  end

  def draw_deck
    SessionCard.find_by_sql(<<~SQL
      select session_cards.* from session_cards
      inner join session_decks on session_decks.id = session_cards.session_deck_id
      where session_cards.game_session_id = #{session.id}
      and session_decks.key like 'draw%'
      and dealt_at is null
      order by session_decks.key, random()
    SQL
    )
  end

  def infect_deck
    SessionCard.find_by_sql(<<~SQL
      select session_cards.* from session_cards
      inner join session_decks on session_decks.id = session_cards.session_deck_id
      where session_cards.game_session_id = #{session.id}
      and session_decks.key like 'infection%'
      and discarded_at is null
      order by session_decks.key DESC, random();
    SQL
    )
  end

  def epidemics
    SessionFrame.find_by_sql(<<~SQL
      select * from session_frames
      inner join session_cards on subject_id = session_cards.id
      inner join cards on session_cards.card_id = cards.id
      where session_frames.game_session_id = #{session.id}
      and subject_type = 'SessionCard'
      and cards.name = 'epidemic'
    SQL
    )
  end

  def epidemic?
    SessionFrame.find_by_sql(<<~SQL
      select * from session_frames
      inner join session_cards on subject_id = session_cards.id
      inner join cards on session_cards.card_id = cards.id
      where session_frames.game_session_id = #{session.id}
      and action = 'card_dealt'
      order by session_frames.id DESC
      limit 2
    SQL
    ).select { |c| c.name == 'epidemic' }.present?
  end

  def deal_initial_cards
    deck = decks.create(key: 'initial')
    dealt_cards = init_draw_pile.shift(player_count * initial_deal_count[player_count.to_s])
    dealt_cards.each do |card|
      SessionCard::Create.!(deck, card: card)
    end
    deck.deal_cards(players, initial_deal_count[player_count.to_s])
  end

  def create_draw_decks
    EPIDEMIC_COUNT.times do |i|
      deck = decks.create(key: "draw-#{i}")
      SessionCard::Create.!(deck, card: game.cards.find_by(name: "epidemic"))
    end
    init_draw_pile.each_with_index do |card, index|
      deck_number = index % EPIDEMIC_COUNT
      SessionCard::Create.!(decks.find_by(key: "draw-#{deck_number}"), card: card)
    end
  end

  def player_play(player, params)
    case params[:player_action]
    when 'draw'
      2.times do
        draw_deck.first.deal(player)
      end
      if epidemic?
        infection = decks.find_by(key: 'infection')
        new_city = infection.cards.shuffle.first
        new_city.update_attributes(
          session_deck: decks.find_by(key: 'infection-discard'),
          discarded_at: Time.zone.now
        )
      end
    when 'infect'
      if epidemic?
        infection_discard = decks.find_by(key: 'infection-discard')
        infection_discard.cards.update_all(discarded_at: nil)
      end
      infection_count[epidemics.count.to_s].times do
        infect_deck.first.discard(player)
      end
      session.advance_turn
    end
  end

  def card_discarded(card)
    card.update_attribute(:session_deck, decks.find_by(key: 'infection-discard'))
  end

  def can_pass?(_player)
    false
  end

  def card_playable?(_card)
    true
  end
end
