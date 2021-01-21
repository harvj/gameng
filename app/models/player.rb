class Player < ApplicationRecord
  belongs_to :user
  belongs_to :session, class_name: 'GameSession', foreign_key: 'game_session_id'
  belongs_to :next_player, class_name: 'Player', optional: true
  belongs_to :role, optional: true

  has_many :cards, class_name: 'SessionCard'
  has_many :frames, class_name: 'SessionFrame', foreign_key: 'acting_player_id'

  validates :user_id, uniqueness: { scope: :game_session_id }

  validate :session_not_in_progress, on: :create
  validate :session_not_full, on: :create

  def play(params)
    SessionFrame::Create.(session,
      action: "player_#{params[:action]}",
      acting_player: self,
      subject: self
    )
    session.game_play.player_play(self, params)
  end

  def pass
    SessionFrame::Create.(session,
      action: 'player_passed',
      acting_player: self,
      subject: self
    )
    session.game_play.player_pass(self)
  end

  def can_pass?
    session.game_play.can_pass?(self)
  end

  private

  def session_not_in_progress
    errors.add(:session, "in progress") if session.started?
  end

  def session_not_full
    errors.add(:session, "has maximum number of players") if session.full?
  end
end
