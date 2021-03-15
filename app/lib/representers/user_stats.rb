module Representers
  class UserStats < Representers::Base
    def build_object(game)
      @game = game
      stats.group_by(&:player_count)
    end

    attr_reader :game

    private

    def stats
      ::Player.find_by_sql(<<~SQL
        SELECT * FROM ( SELECT
          username,
          player_count,
          array_agg(score),
          avg(score)::integer AS average,
          max(score) AS high_score,
          min(score) AS low_score,
          count(CASE WHEN x.winner THEN 1 END) AS wins,
          count(x) AS games_played,
          max(cards_table.cards_per) as doubles_per
        FROM (
          SELECT
            users.username,
            players.score,
            players.winner,
            (SELECT count(*) FROM players WHERE players.game_session_id = game_sessions.id) AS player_count
          FROM players
          JOIN users ON players.user_id = users.id
          JOIN game_sessions ON players.game_session_id = game_sessions.id
          WHERE players.score IS NOT NULL
          AND game_sessions.game_id = #{game.id}
        ) AS x
        JOIN (
          SELECT users.username as cards_username,
            round(count(session_cards.id)::decimal / count(distinct session_cards.game_session_id), 2) AS cards_per,
            (SELECT count(*) FROM players WHERE players.game_session_id = game_sessions.id) AS cards_player_count
          FROM session_cards
          JOIN game_sessions on session_cards.game_session_id = game_sessions.id
          JOIN cards on cards.id = session_cards.card_id
          JOIN players on session_cards.player_id = players.id and players.score IS NOT NULL
          JOIN users on players.user_id = users.id
          WHERE game_sessions.game_id = #{game.id}
          AND cards.value = 'double'
          GROUP BY cards_username, cards_player_count
        ) AS cards_table ON cards_table.cards_username = x.username AND cards_table.cards_player_count = x.player_count
        GROUP BY x.username, player_count
        ORDER BY player_count DESC, average DESC
      ) AS y WHERE y.games_played > 1
      SQL
      )
    end
  end
end
