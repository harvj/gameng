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

  def find_players(count=4)
    users = User.limit(count)
    users.each do |user|
      players.create(user_id: user.id)
    end
  end
end
