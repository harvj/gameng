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
          count(CASE WHEN x.winner THEN 1 END) AS win_count,
          count(x) AS games_played
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
        GROUP BY x.username, player_count
        ORDER BY player_count DESC, average DESC
      ) AS y WHERE y.games_played > 1
      SQL
      )
    end
  end
end
