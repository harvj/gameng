class SessionFrame < ApplicationRecord
  belongs_to :game_session

  belongs_to :active_player, class_name: 'Player', optional: true
  belongs_to :affected_player, class_name: 'Player', optional: true
  belongs_to :subject, polymorphic: true

  validates :action, presence: true

  def created_at_milli
    created_at.to_datetime.strftime('%Q').to_i
  end
end
