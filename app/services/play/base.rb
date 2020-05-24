class Play::Base
  include ServiceObject

  attr_reader :session

  def initialize(game_session=nil)
    @session = game_session || GameSession::Create.(game).subject
  end

  def call
    if playable?
      send(next_action)
      session.update_attribute(:state, next_action)
    else
      log("Session in #{session.state} state cannot be played.")
    end
  end

  def playable?
    sequence.index(session.state.to_sym).present?
  end

  def next_action
    sequence[next_action_index]
  end

  def next_action_index
    sequence.index(session.state.to_sym) + 1
  end

  def game
    @game ||= Game.find_by(slug: self.class.name.demodulize.underscore)
  end

  def sequence
    self.class::SEQUENCE
  end
end
