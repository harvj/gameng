class Player < ApplicationRecord
  belongs_to :user
  belongs_to :game_session

  has_many :cards, class_name: 'SessionCard'

  validates :user_id, uniqueness: { scope: :game_session_id }
end
