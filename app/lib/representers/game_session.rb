module Representers
  class GameSession < Representers::Base
    attr_reader :session, :config

    def build_object(session)
      @session = session
      @config = session.game_class.new(session)

      scalar = {
        active: session.active?,
        completed: session.completed_at.present?,
        completedAt: session.completed_at&.strftime('%a %e %b %Y %k:%M:%S'),
        completedAtDate: session.completed_at&.strftime('%e %b %Y'),
        joinable: config.joinable?,
        nextActionText: config.next_action_text[config.next_action&.to_sym],
        playable: config.playable?,
        playerCount: session.players.count,
        started: session.started_at.present?,
        startedAt: session.started_at&.strftime('%a %e %b %Y %k:%M:%S'),
        startedAtDate: session.started_at&.strftime('%e %b %Y'),
        state: session_state,
        states: transition_frames.map { |frame| { frame.action => frame.created_at_micro } },
        uid: session.uid,
        uri: game_session_path(session.uid),
        waiting: session.waiting?
      }
      return scalar if scalar_only?

      scalar.merge(
        cards: Representers::SessionCard.(session.cards),
        game: Representers::Game.(session.game, scalar: true),
        players: Representers::Player.(session.players, scalar: true)
      )
    end

    def session_state
      if session.waiting?
        config.playable? ? 'Ready to begin': 'Waiting for players...'
      else
        session.state.titleize
      end
    end

    def transition_frames
      session.frames.where(action: session.game_class::PLAY_SEQUENCE)
    end
  end
end
