class SessionDeck < ApplicationRecord
  belongs_to :game_session
  has_many :cards, class_name: 'SessionCard'

  def deal_cards(users, count)
    count.times do
      users.each do |user|
        next_card.deal(user)
      end
    end
  end

  def next_card
    cards.undealt.shuffled.limit(1).first
  end
end
