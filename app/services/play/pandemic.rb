class Play::Pandemic < Play::Base
  PLAY_SEQUENCE = [].freeze

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

  EPIDEMIC_COUNT = 5

  INIT_DEAL_COUNTS = { '2' => 4, '3' => 3, '4' => 2 }.freeze

  INFECTION_DEAL_COUNTS = { '0' => 2, '1' => 2, '2' => 2, '3' => 3, '4' => 3, '5' => 4, '6' => 4 }.freeze

  PLAYER_ACTIONS = {
    inactive: %w(trade),
    draw: %w(trade draw),
    infect: %w(infect),
    trade: %w(cancel submit_trade),
    discard: %w()
  }

  attr_accessor :init_draw_pile

  def initial_deal_count
    INIT_DEAL_COUNTS[players.count.to_s]
  end

  def infection_count
    INFECTION_DEAL_COUNTS[epidemic_count.to_s]
  end

  def possible_player_actions(player)
    return [] if resilient_pop?
    PLAYER_ACTIONS[player.action_phase.to_sym]
  end

  def player_draw(player)
    2.times do
      if card = deck_cards('draw').first
        card.deal(player)
      else
        transition_state and break
      end
    end
    player.update_attribute(:action_phase, 'infect')
    if epidemic?
      session.cards.by_card_key('epidemic').active.last&.discard(player)
      if !session.completed?
        new_city = decks.find_by(key: 'infection').cards.shuffle.first
        new_city.deal
        new_city.update_attribute(:session_deck, decks.find_by(key: "infection-#{epidemic_count - 1}"))
      end
    end
    check_hand_limit(player)
  end

  def player_infect(player)
    if epidemic?
      infected.update_all(dealt_at: nil)
      decks.create(key: "infection-#{epidemic_count}")
    end
    if one_quiet_night?
      session.update_attribute(:special_game_phase, nil)
    else
      infection_count.times do
        infecting_city = deck_cards('infection').first
        infecting_city.deal
        infecting_city.update_attribute(:session_deck, decks.find_by(key: "infection-#{epidemic_count}"))
      end
    end
    session.advance_turn
  end

  def player_trade(player)
    player.update_attributes(
      action_phase_revert: player.action_phase,
      action_phase: 'trade',
    )
  end

  def player_submit_trade(player, params)
    card = player.cards.find(params['card']['id'])
    receiving_player = session.players.find(params['player']['id'])
    if card.present? && receiving_player.present?
      card.update_attribute(:player, receiving_player)
      check_hand_limit(receiving_player)
    end
    player.update_attribute(:action_phase, player.action_phase_revert)
  end

  def player_cancel(player)
    player.update_attribute(:action_phase, player.action_phase_revert)
  end

  def player_actionable?(player)
    return false if !session.started? || session.completed?
    current_player&.action_phase == 'trade' && player != current_player
  end

  def card_dealt(session_card)
    session_card.update_attribute(:session_deck, decks.find_by(key: "infection-#{epidemic_count}")) if session_card.card.key == 'infection'
  end

  def card_played(session_card)
    card = session_card.card
    case card.name
    when 'resilient pop', 'one quiet night'
      session.update_attribute(:special_game_phase, card.name)
    end
    check_hand_limit(session_card.player)
  end

  def card_playable?(card)
    return false if resilient_pop?
    return false if current_player.action_phase == 'infect' && card.value != 'special'
    card.key === 'player'
  end

  def card_playable_out_of_turn?(card)
    card.value == 'special'
  end

  def card_discarded(session_card)
    if resilient_pop?
      session.update_attribute(:special_game_phase, nil)
    else
      check_hand_limit(session_card.player)
    end
  end

  def card_discardable?(session_card)
    card = session_card.card
    player = session_card.player

    return true if card.key == 'epidemic'
    return card.key == 'infection' if resilient_pop?
    return false if player.nil?
    return card.key == 'player' && card.value != 'special' if player.action_phase == 'discard'
    false
  end

  def card_tradeable?(card)
    card.key == 'player' && card.value != 'special'
  end

  def start_turn(player)
    player.update_attribute(:action_phase, 'draw')
  end

  def end_turn(player)
    player.update_attribute(:action_phase, 'inactive')
  end

  def check_hand_limit(player)
    if player.action_phase == 'discard'
      player.update_attribute(:action_phase, player.action_phase_revert) if player.cards.active.count <= 7
    elsif player.cards.active.count > 7
      player.update_attributes(
        action_phase_revert: player.action_phase,
        action_phase: 'discard'
      )
    end
  end

  def build_card_decks
    create_infection_decks
    deal_initial_cards
    create_draw_decks
  end

  def create_infection_decks
    infection = decks.create(key: 'infection')
    game.cards.where(key: 'infection').each do |card|
      SessionCard::Create.!(infection, card: card)
    end

    infection_discard = decks.create(key: 'infection-0')
    infection.cards.shuffle.first(9).each do |card|
      card.update_attribute(:session_deck, infection_discard)
      card.deal
    end
  end

  def deal_initial_cards
    deck = decks.create(key: 'initial')
    dealt_cards = init_draw_pile.shift(players.count * initial_deal_count)
    dealt_cards.each do |card|
      SessionCard::Create.!(deck, card: card)
    end
    deck.deal_cards(players, initial_deal_count)
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

  def display_card_groups
    result = [
      { name: 'infections', cards: infected },
      { name: 'draw deck', count: deck_cards('draw').count, cards: [] }
    ]
    if res_pop = session.cards.by_card_key('infection').discarded.first
      result << { name: 'resilient population', cards: [res_pop] }
    end
    result
  end

  # --- Queries

  def init_draw_pile
    @init_draw_pile ||= game.cards.where(key: 'player').shuffle
  end

  def infected
    session.cards.by_card_key('infection').active.order('dealt_at DESC')
  end

  def deck_cards(key)
    SessionCard.find_by_sql(<<~SQL
      select session_cards.* from session_cards
      inner join session_decks on session_decks.id = session_cards.session_deck_id
      where session_cards.game_session_id = #{session.id}
      and session_decks.key like '#{key}%'
      and dealt_at is null
      and discarded_at is null
      order by session_decks.key DESC, random()
    SQL
    )
  end

  def epidemic_count
    SessionFrame.find_by_sql(<<~SQL
      select count(*) from session_frames
      inner join session_cards on subject_id = session_cards.id
      inner join cards on session_cards.card_id = cards.id
      where session_frames.game_session_id = #{session.id}
      and subject_type = 'SessionCard'
      and action = 'card_dealt'
      and cards.name = 'epidemic'
    SQL
    ).first.count
  end

  def epidemic?
    SessionFrame.find_by_sql(<<~SQL
      select * from session_frames
      inner join session_cards on subject_id = session_cards.id
      inner join cards on session_cards.card_id = cards.id
      where session_frames.game_session_id = #{session.id}
      and key <> 'infection'
      and action = 'card_dealt'
      order by session_frames.id DESC
      limit 2
    SQL
    ).select { |c| c.name == 'epidemic' }.present?
  end

  def resilient_pop?
    session.special_game_phase == 'resilient pop'
  end

  def one_quiet_night?
    session.special_game_phase == 'one quiet night'
  end

  def player_action_prompt(player)
    return unless session.started? && session.current_player
    if player.inactive?
      "#{session.current_player.user.name}'s turn..."
    elsif resilient_pop?
      "Resilient population... Choose an infected city to discard..."
    elsif one_quiet_night?
      "One quiet night... Next infection will not deal cards..."
    elsif player.action_phase == 'draw'
      "Your turn. Choose cards to play or draw 2..."
    elsif player.action_phase == 'trade'
      "Trading... Click a card and a player to trade it to..."
    elsif player.action_phase == 'discard'
      "Hand limit reached... click cards to discard or play specials..."
    else
      "Your turn to infect..."
    end
  end
end
