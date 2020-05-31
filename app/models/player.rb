class Player < ApplicationRecord
  belongs_to :user
  belongs_to :game_session

  has_many :cards, class_name: 'SessionCard'

  validates :user_id, uniqueness: { scope: :game_session_id }

  validate :session_not_in_progress
  validate :session_not_full

  private

  def session_not_in_progress
    errors.add(:game_session, "in progress") if game_session.started?
  end

  def session_not_full
    errors.add(:game_session, "has maximum number of players") if game_session.full?
  end
end
