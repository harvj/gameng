class GameSession < ApplicationRecord
  BEGIN_STATES = %i(waiting started)
  END_STATES   = %i(completed)

  belongs_to :game
  has_many :players, dependent: :destroy

  has_many :decks, class_name: 'SessionDeck', dependent: :destroy

  def start!
    self.update_attribute(:started_at, Time.zone.now)
  end

  def started?
    started_at.present?
  end

  def complete!
    self.update_attribute(:ended_at, Time.zone.now)
  end

  def completed?
    ended_at.present?
  end

  def waiting?
    state == 'waiting'
  end

  def game_class
    "Play::#{game.slug.classify}".safe_constantize
  end
end
