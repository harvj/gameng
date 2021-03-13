class UserBadge < ApplicationRecord
  belongs_to :badge
  belongs_to :user
  belongs_to :as_of_session, class_name: 'GameSession'

  scope :active, -> { find_by(active: true) }
end
