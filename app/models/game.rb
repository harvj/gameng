class Game < ApplicationRecord
  has_many :cards
  has_many :sessions, class_name: 'GameSession', dependent: :destroy
end
