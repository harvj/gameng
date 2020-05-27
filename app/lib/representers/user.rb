module Representers
  class User < Representers::Base
    def build_object(user)
      {
        name: user.name,
        username: user.username
      }
    end
  end
end
