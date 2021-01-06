class GameSession < ApplicationRecord
  BEGIN_STATES = %w(waiting started)
  END_STATES   = %w(completed)

  belongs_to :game
  belongs_to :current_player, class_name: 'Player', optional: true

  has_many :players, -> { order('turn_order asc') }, dependent: :destroy
  has_many :decks, class_name: 'SessionDeck', dependent: :destroy
  has_many :cards, class_name: 'SessionCard', dependent: :destroy
  has_many :frames, class_name: 'SessionFrame', dependent: :destroy

  validates :uid, presence: true, uniqueness: true
  validates :state, presence: true

  delegate :play_class, :min_players, :max_players,
    to: :game

  scope :played_card_counts_by_name, ->(session, state_name) { find_by_sql(<<~SQL
      select count(*), cards.name from session_cards
      inner join session_frames on session_frames.subject_id = session_cards.id and session_frames.subject_type = 'SessionCard'
      inner join cards on cards.id = session_cards.card_id
      where session_cards.game_session_id = #{session.id}
      and session_frames."action" = 'card_played'
      and session_frames."state" = '#{state_name}'
      group by cards.name
    SQL
    )
  }

  def game_play
    play_class.new(self)
  end

  def self.generate_uid
    Passphrase::Passphrase.new(number_of_words: 4).passphrase.tr(' ','-')
  end

  def play_sequence
    BEGIN_STATES + play_class::PLAY_SEQUENCE + END_STATES
  end

  def start!
    update_attribute(:started_at, Time.zone.now)
  end

  def started?
    started_at.present?
  end

  def next_action
    next_index = play_sequence.index(state) + 1
    play_sequence[next_index]
  end

  def next_action_prompts
    prompts = {}
    play_class::PLAY_SEQUENCE.each { |i| prompts[i] = "Play #{i.titleize}" }
    prompts.merge(
      'started' => "Start with #{players.count} players",
      'completed' => "Finish Game"
    )
  end

  def next_action_prompt
    next_action_prompts[next_action]
  end

  def advance_turn
    update_attribute(:current_player, current_player.next_player)
  end

  def played_card_counts_by_name(state_name)
    GameSession.played_card_counts_by_name(self, state_name)
  end

  def available_roles
    game.roles.joins("LEFT JOIN players ON players.role_id = roles.id").where("players.game_session_id = #{id} AND roles.id IS NULL")
  end

  def state_transitions
    frames.where(action: play_sequence).reduce({}) do |result, frame|
      result[frame.action] = frame.created_at_milli
      result
    end
  end

  def display_state
    if waiting?
      playable? ? 'Ready to begin': 'Waiting for players...'
    else
      state.titleize
    end
  end

  def waiting?
    state == 'waiting'
  end

  def full?
    players.count == max_players
  end

  def joinable?
    !full? && !started?
  end

  def playable?
    players.count >= min_players && !completed?
  end

  def active?
    !waiting? && !completed?
  end

  def complete!
    update_attribute(:completed_at, Time.zone.now)
  end

  def completed?
    completed_at.present?
  end
end
