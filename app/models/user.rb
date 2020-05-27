class User < ApplicationRecord
  devise :database_authenticatable, authentication_keys: [:username]

  validates :username, uniqueness: true
end
