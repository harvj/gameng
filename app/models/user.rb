class User < ApplicationRecord
  devise :database_authenticatable, authentication_keys: [:username]

  has_many :players
  has_one :user_config

  validates :username, uniqueness: true
  validates :name, uniqueness: true

  def config
    user_config
  end

  def to_param
    username
  end
end
