module Representers
  class GameSession < Representers::Base
    attr_reader :session

    def build_object(session)
      scalar = {
        active: session.active?,
        archived: session.completed_at.present? && session.completed_at < 2.months.ago,
        completed: session.completed_at.present?,
        completedAt: session.completed_at&.strftime('%a %e %b %Y %k:%M:%S'),
        completedAtDate: session.completed_at&.strftime('%e %b %Y'),
        createdAt: session.created_at.to_i,
        joinable: session.joinable?,
        nextActionPrompt: session.next_action_prompt,
        playable: session.playable?,
        playerCount: session.players.count,
        started: session.started_at.present?,
        startedAt: session.started_at&.strftime('%a %e %b %Y %k:%M:%S'),
        startedAtDate: session.started_at&.strftime('%e %b %Y'),
        state: session.display_state,
        stateTransitions: session.state_transitions,
        terms: session.play_class::TERMS,
        uid: session.uid,
        uri: game_session_path(session.uid),
        waiting: session.waiting?
      }
      return scalar if scalar_only?

      scalar.merge!(
        decks: Representers::SessionDeck.(session.decks),
        game: Representers::Game.(session.game, scalar: true),
        players: Representers::Player.(session.players, scalar: true)
      )

      scalar.merge!(currentPlayer: Representers::Player.(session.current_player, scalar: true)) if session.current_player.present?

      logged_in_player = session.players.find_by(user: user)
      scalar.merge!(loggedInPlayer: Representers::Player.(logged_in_player)) if logged_in_player.present?

      scalar
    end
  end
end
