class Play::Base
  include ServiceObject

  def initialize(game_session=nil)
    @game = Game.find_by(slug: self.class.name.demodulize.underscore)
    @session = game_session || GameSession::Create.(game).subject
  end

  attr_reader :session, :game

  def sequence
    GameSession::BEGIN_STATES + self.class::PLAY_SEQUENCE + GameSession::END_STATES
  end

  def call
    if playable?
      send(next_action)
      session.update_attribute(:state, next_action) if ok?
    end
    Services::Response.new(subject: session, errors: errors)
  end

  def joinable?
    session.players.count < self.class::MAXIMUM_PLAYERS && !session.started?
  end

  def playable?
    session.players.count >= self.class::MINIMUM_PLAYERS && !session.completed?
  end

  def started
    session.start!
  end

  def completed
    session.complete!
  end

  def next_action
    next_index = sequence.index(session.state.to_sym) + 1
    sequence[next_index]
  end

  def next_action_text
    {
      started: "Start with #{session.players.count} players",
      completed: "Finish Game"
    }
  end

  def build_deck(slug)
    deck = session.decks.create(slug: slug)
    self.class::DECKS[slug].each do |name, value_counts|
      value_counts.each do |value, count|
        count.times do
          card = game.cards.find_by(name: name, value: value)
          deck.cards.create(card_id: card.id)
        end
      end
    end
  end
end
