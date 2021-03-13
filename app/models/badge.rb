class Badge < ApplicationRecord
  belongs_to :game
  has_many :user_badges
end
