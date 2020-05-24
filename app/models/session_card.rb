class SessionCard < ApplicationRecord
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
end
