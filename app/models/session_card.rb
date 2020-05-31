class SessionCard < ApplicationRecord
  belongs_to :session, class_name: 'GameSession', foreign_key: 'game_session_id'
  belongs_to :session_deck
  belongs_to :card
  belongs_to :player, optional: true

  scope :dealt,    -> { where('dealt_at IS NOT NULL')}
  scope :undealt,  -> { where('dealt_at IS NULL') }
  scope :shuffled, -> { order('random()') }

  def deal(player=nil)
    self.dealt_at = Time.zone.now
    self.player_id = player.id if player.present?
    log("#{card.name}: #{card.value} dealt to #{player.user.name}")
    save
  end

  def play(affected_player=nil)
    update_attribute(:played_at, Time.zone.now)
    session.frames.create(
      subject: self,
      action: 'card_played',
      active_player: player,
      affected_player: affected_player
    )
  end

  def status
    return 'deck' if !dealt?
    return 'playable' if playable?
    return 'played' if played?
    return 'discarded' if discarded?
    'unknown'
  end

  def playable?
    dealt? && !played? && !discarded?
  end

  def dealt?
    dealt_at.present?
  end

  def dealt_at_milli
    return unless dealt?
    dealt_at.to_datetime.strftime('%Q').to_i
  end

  def dealt_during_state
    return unless dealt?
    result = nil
    session.state_transitions.each do |state, started_at|
      break if dealt_at_milli < started_at
      result = state
    end
    result
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
