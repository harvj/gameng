class GameSession < ApplicationRecord
  BEGIN_STATES = %i(waiting started)
  END_STATES   = %i(completed)

  belongs_to :game

  has_many :players, dependent: :destroy
  has_many :decks, class_name: 'SessionDeck', dependent: :destroy
  has_many :cards, class_name: 'SessionCard', dependent: :destroy
  has_many :frames, class_name: 'SessionFrame', dependent: :destroy

  validates :uid, presence: true, uniqueness: true
  validates :state, presence: true

  def self.generate_uid
    Passphrase::Passphrase.new(number_of_words: 4).passphrase.tr(' ','-')
  end

  def active?
    !waiting? && !completed?
  end

  def start!
    self.update_attribute(:started_at, Time.zone.now)
  end

  def started?
    started_at.present?
  end

  def complete!
    self.update_attribute(:completed_at, Time.zone.now)
  end

  def completed?
    completed_at.present?
  end

  def waiting?
    state == 'waiting'
  end

  def game_class
    "Play::#{game.slug.classify}".safe_constantize
  end
end
