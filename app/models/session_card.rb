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

  def active?
    dealt_at.present? && played_at.nil? && discarded_at.nil?
  end

  def dealt_at_micro
    [dealt_at&.to_i, dealt_at&.usec].join.to_i
  end

  def discarded_at_micro
    [discarded_at&.to_i, discarded_at&.usec].join.to_i
  end

  def played_at_micro
    [played_at&.to_i, played_at&.usec].join.to_i
  end
end
