class Play::Base
  include ServiceObject

  def initialize(game_session=nil, active_user=nil)
    @session     = game_session || create_session!
    @active_user = active_user
  end

  attr_reader :session, :active_user

  delegate :next_action, :players, :frames,
    to: :session

  def call
    transition_state if session.playable?
    Services::Response.new(subject: session, errors: errors)
  end

  def create_session!
    game = Game.find_by(key: self.class.name.demodulize.underscore)
    GameSession::Create.!(game).subject
  end

  def active_player
    return unless active_user.present?
    @active_player ||= players.find_by(user_id: active_user.id)
  end

  def started
    active_player.update_attribute(:moderator, true)
    session.start!
    build_card_decks!
  end

  def completed
    session.complete!
  end

  def transition_state
    frames.create!(action: next_action, subject: session)
    send(next_action)
    session.update_attribute(:state, next_action) if ok?
  end

  def build_card_decks!
    self.class::DECKS.each do |key, attrs|
      deck = session.decks.create!(key: key)
      attrs.each do |name, value_counts|
        value_counts.each do |value, count|
          count.times do
            SessionCard::Create.!(deck, card: session.game.cards.find_by(name: name, value: value))
          end
        end
      end
    end
  end
end
