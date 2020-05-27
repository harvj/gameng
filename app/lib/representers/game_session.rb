module Representers
  class GameSession < Representers::Base
    attr_reader :session, :config

    def build_object(session)
      @session = session
      @config = session.game_class.new(session)
      {
        uid: session.uid,
        state: session_state,
        startedAt: session.started_at&.strftime('%a %e %b %Y %k:%M:%S'),
        endedAt: session.ended_at&.strftime('%a %e %b %Y %k:%M:%S'),
        uri: game_session_path(session.uid),
        game: Representers::Game.(session.game, scalar: true),
        players: Representers::Player.(session.players, session: session),
        decks: decks,
        config: rep_config
      }
    end

    def session_state
      if session.waiting?
        config.playable? ? 'Ready to begin': 'Waiting for players...'
      else
        session.state.titleize
      end
    end

    def rep_config
      {
        joinable: config.joinable?,
        playable: config.playable?,
        nextActionText: config.next_action_text[config.next_action&.to_sym]
      }
    end

    def decks
      session.decks.map do |deck|
        {
          slug: deck.slug,
          card_count: deck.cards.count
        }
      end
    end
  end
end
