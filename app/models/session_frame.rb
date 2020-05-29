class SessionFrame < ApplicationRecord
  belongs_to :game_session

  belongs_to :active_player, class_name: 'Player', optional: true
  belongs_to :affected_player, class_name: 'Player', optional: true
  belongs_to :subject, polymorphic: true

  validates :action, presence: true

  def created_at_micro
    [created_at.to_i, created_at.usec].join.to_i
  end
end
