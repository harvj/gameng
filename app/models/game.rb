class Game < ApplicationRecord
  has_many :cards
  has_many :game_sessions
end
