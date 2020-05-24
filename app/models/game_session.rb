class GameSession < ApplicationRecord
  belongs_to :game
  has_many :players, dependent: :destroy
  has_many :users, through: :players

  has_many :decks, class_name: 'SessionDeck', dependent: :destroy

  def start!
    self.update_attribute(:state, 'started')
  end

  def find_players(count=4)
    users = User.limit(count)
    users.each do |user|
      players.create(user_id: user.id)
    end
    start!
  end
end
