class SessionCard < ApplicationRecord
  belongs_to :game_session
  belongs_to :session_deck
  belongs_to :card
  belongs_to :player, optional: true

  scope :undealt,  -> { where(dealt_at: nil) }
  scope :shuffled, -> { order('random()') }

  def deal(player=nil)
    self.dealt_at = Time.zone.now
    self.player_id = player.id if player.present?
    log("#{card.name}: #{card.value} dealt to #{player.user.name}")
    save
  end

  def play
    update_attribute(:played_at, Time.zone.now)
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

  def dealt_at_micro
    [dealt_at&.to_i, dealt_at&.usec].join.to_i
  end

  def discarded?
    discarded_at.present?
  end

  def discarded_at_micro
    [discarded_at&.to_i, discarded_at&.usec].join.to_i
  end

  def played?
    played_at.present?
  end

  def played_at_micro
    [played_at&.to_i, played_at&.usec].join.to_i
  end
end
