module GameBuild
  class Base
    include ServiceObject

    USER_PASSWORD = 'foobar'.freeze
    DEFAULT_USERS = [
      { name: 'rAdio',           email: 'jimrharvey@gmail.com' },
      { name: 'Ken Griffey Jr.', email: 'jr@griffey.com' },
      { name: 'Herbie Hancock',  email: 'herbie@hancock.com' },
      { name: 'Michael Jordan',  email: 'jordan@bulls.com' },
      { name: 'Kate Bush',       email: 'kate@bush.com' }
    ].freeze

    def call
      create_users
      add_game
    end

    private

    def create_users
      DEFAULT_USERS.each do |params|
        next if User.find_by(email: params[:email]).present?
        log("building User: #{params}")
        User.create(params.merge(password: USER_PASSWORD))
      end
    end

    def create_game(params)
      log("building Game: #{params}")
      Game.create(params)
    end

    def create_card(params)
      log("building Card: #{params}")
      Card.create(params)
    end
  end
end
