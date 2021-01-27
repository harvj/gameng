module Representers
  class GameSession < Representers::Base
    attr_reader :session

    def build_object(session)
      scalar = {
        active: session.active?,
        allowDisplayPlayerSwitching: session.allow_display_player_switching?,
        archived: session.completed_at.present? && session.completed_at < 2.months.ago,
        completed: session.completed_at.present?,
        completedAt: session.completed_at&.strftime('%a %e %b %Y %k:%M:%S'),
        completedAtDate: session.completed_at&.strftime('%e %b %Y'),
        createdAt: session.created_at.to_i,
        joinable: session.joinable?,
        nextActionPrompt: session.next_action_prompt,
        playable: session.playable?,
        playerCount: session.players.count,
        promptForPlayerScore: session.prompt_for_player_score?,
        showInactiveCards: session.show_inactive_cards?,
        specialGamePhase: session.special_game_phase,
        started: session.started_at.present?,
        startedAt: session.started_at&.strftime('%a %e %b %Y %k:%M:%S'),
        startedAtDate: session.started_at&.strftime('%e %b %Y'),
        state: session.display_state,
        terms: session.play_class::TERMS,
        uid: session.uid,
        uri: game_session_path(session.uid),
        waiting: session.waiting?
      }
      return scalar if scalar_only?

      scalar.merge!(
        displayCardGroups: session.display_card_groups.map do |group|
          {
            name: group[:name],
            count: group[:count],
            cards: Representers::SessionCard.(group[:cards])
          }
        end,
        game: Representers::Game.(session.game, scalar: true),
        players: Representers::Player.(session.players)
      )

      scalar.merge!(currentPlayerId: session.current_player.id, currentPlayerName: session.current_player.user.name) if session.current_player.present?

      logged_in_player = session.players.find_by(user: user)
      scalar.merge!(loggedInPlayer: Representers::Player.(logged_in_player)) if logged_in_player.present?

      scalar
    end
  end
end
