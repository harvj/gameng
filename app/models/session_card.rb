class SessionCard < ApplicationRecord
  belongs_to :session, class_name: 'GameSession', foreign_key: 'game_session_id'
  belongs_to :session_deck
  belongs_to :card
  belongs_to :player, optional: true

  scope :dealt,    -> { where('dealt_at IS NOT NULL') }
  scope :undealt,  -> { where('dealt_at IS NULL') }
  scope :played,   -> { where('played_at IS NOT NULL') }
  scope :shuffled, -> { order('random()') }

  def deal(player=nil)
    update_attributes(
      dealt_at: Time.zone.now,
      player: player
    )
    SessionFrame::Create.(session,
      action: 'card_dealt',
      affected_player: player,
      subject: self
    )
    log("#{card.name}: #{card.value} dealt to #{player.user.name}")
  end

  def play(affected_player=nil)
    update_attribute(:played_at, Time.zone.now)
    SessionFrame::Create.(session,
      action: 'card_played',
      acting_player: player,
      affected_player: affected_player,
      subject: self
    )
    session.game_play.card_played(card)
  end

  def status
    return 'deck' if !dealt?
    return 'played' if played?
    return 'playable' if playable?
    return 'discarded' if discarded?
    'unplayable'
  end

  def playable?
    dealt? && !played? && !discarded? && session.game_play.card_playable?(card)
  end

  def dealt?
    dealt_at.present?
  end

  def dealt_at_milli
    return unless dealt?
    dealt_at.to_datetime.strftime('%Q').to_i
  end

  def dealt_during_state
    session.frames.find_by(subject: self, action: 'card_dealt')&.state
  end

  def discarded?
    discarded_at.present?
  end

  def discarded_at_milli
    return unless discarded?
    discarded_at.to_datetime.strftime('%Q').to_i
  end

  def played?
    played_at.present?
  end

  def played_at_milli
    return unless played?
    played_at.to_datetime.strftime('%Q').to_i
  end
end
