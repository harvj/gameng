class Play::Base
  include ServiceObject

  def initialize(game_session=nil, active_user=nil)
    @session     = game_session || create_session!
    @active_user = active_user
  end

  attr_reader :session, :active_user

  delegate :game, :players, :decks, :next_action, :frames, :current_player,
    to: :session

  def call
    Game.transaction { transition_state if session.playable? }
    Services::Response.new(subject: session, errors: errors)
  end

  def create_session!
    game = Game.find_by(key: self.class.name.demodulize.underscore)
    GameSession::Create.!(game).subject
  end

  def active_player
    return unless active_user.present?
    @active_player ||= players.find_by(user_id: active_user.id)
  end

  def started
    active_player.update_attribute(:moderator, true)
    session.start!
    build_card_decks
    set_turn_order
  end

  def set_turn_order
    randomized_players = players.shuffle
    randomized_roles = game.roles.shuffle.first(players.count)
    first_player = randomized_players[0]

    randomized_players.each_with_index do |player, index|
      player.update_attributes!(
        role: randomized_roles[index],
        turn_order: index + 1,
        next_player: randomized_players[index + 1] || first_player
      )
    end
    first_player.start_turn
    session.update_attribute(:current_player, first_player)
  end

  def completed
    session.complete!
  end

  def transition_state
    action = next_action
    session.update_attribute(:state, action)
    SessionFrame::Create.(session,
      action: action,
      acting_player: active_player,
      subject: session
    )
    send(action)
  end

  def last_card_played
    last_session_card_played&.card
  end

  def last_session_card_played
    last_card_played_frame&.subject
  end

  def last_card_played_frame
    session.frames.where(subject_type: 'SessionCard', action: 'card_played', state: session.state).last
  end

  # --- methods to define per game

  def build_card_decks
  end

  def display_cards
    []
  end

  def card_played(_card)
  end

  def card_discarded(_card)
  end

  def player_action(player, action: nil, params: {})
    return if !player.possible_actions.include?(action)
    if params.present?
      send("player_#{action}", player, params)
    else
      send("player_#{action}", player)
    end
  end

  def start_turn(_player)
  end

  def end_turn(_player)
  end

  def card_playable?(_card)
    false
  end

  def card_playable_out_of_turn?(_card)
    false
  end
end
