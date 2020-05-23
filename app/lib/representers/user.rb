module Representers
  class User < Representers::Base
    def build_object(user)
      {
        email: user.email
      }
    end
  end
end
