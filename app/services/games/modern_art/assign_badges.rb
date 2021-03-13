module Games
  class ModernArt::AssignBadges
    include ServiceObject

    def initialize
      @game = Game.find_by(key: 'modern_art')
      @last_session = game.sessions.completed.last
    end

    def call
      assign_dog_man
      assign_card_badges
      assign_win_streak
    end

    attr_reader :game, :last_session

    def assign_dog_man
      dog_badge = game.badges.find_by(name: 'dog_man')
      active = dog_badge.user_badges.active
      return if active.present? && active.as_of_session == last_session

      players = non_winners_from_date(last_session.completed_at)
      results = {}

      players.group_by { |player| player.username }.each do |username, sessions|
        stddevs = sessions.map do |session|
          diff = session.score - score_stats(session.player_count).avg
          diff.to_f / score_stats(session.player_count).stddev
        end
        results[username] = stddevs.sum / stddevs.length
      end

      dog_user, dog_score = results.min_by {|name, score| score}

      active.update_attribute(active: false) if active.present?
      UserBadge.create(
        badge: dog_badge,
        user: User.find_by(username: dog_user),
        value: dog_score.round(2).to_f,
        as_of_session: last_session
      )
    end

    def assign_card_badges
      %i(lite_metal yoko cristin_p gitter krypto fixed double open sealed once_around).each do |card_type|
        %i(up down).each do |direction|
          badge = game.badges.find_by(name: "#{card_type}_#{direction}")
          next if badge.nil?
          active = badge.user_badges.active
          next if active.present? && active.as_of_session == last_session

          active.update_attribute(active: false) if active.present?
          which_one = direction == 'up' ? 'last' : 'first'
          badge_winner = card_stats.sort_by{|p| p.send("#{card_type}_crown")}.send(which_one)
          UserBadge.create(
            badge: badge,
            user: User.find_by(username: badge_winner.username),
            value: badge_winner.send("#{card_type}_crown").round(1).to_f,
            as_of_session: last_session
          )
        end
      end
    end

    def assign_win_streak
      badge = game.badges.find_by(name: 'win_streak')
      active = badge.user_badges.active
      return if active.present? && active.as_of_session == last_session

      active.update_attribute(active: false) if active.present?
      badge_winner = last_session.winner.user
      value = active.present? && badge_winner == active.user ? active.value + 1 : 1
      UserBadge.create(
        badge: badge,
        user: User.find_by(username: badge_winner.username),
        value: value,
        as_of_session: last_session
      )
    end

    def score_stats(player_count)
      return @score_stats if @score_stats.present?
      @score_stats = Player.find_by_sql(<<~SQL
        SELECT
          avg(players.score)::INTEGER,
          stddev(players.score)::INTEGER
        FROM players
        JOIN game_sessions ON game_sessions.id = game_session_id
        JOIN games ON games.id = game_sessions.game_id
        WHERE games.id = #{game.id}
        AND (SELECT count(*) FROM players p WHERE p.game_session_id = players.game_session_id) = #{player_count}
        AND players.score IS NOT NULL
      SQL
      ).first
    end

    def non_winners_from_date(date)
      Player.find_by_sql(<<~SQL
        SELECT
          users.username,
          players.score,
          (SELECT count(*) FROM players WHERE players.game_session_id = game_sessions.id) AS player_count
        FROM game_sessions
        JOIN players ON players.game_session_id = game_sessions.id
        JOIN users ON players.user_id = users.id
        WHERE timezone('US/Pacific', completed_at AT TIME ZONE 'utc')::DATE = '#{date.strftime('%Y-%m-%d')}'
        AND users.id NOT IN
          ( SELECT DISTINCT user_id FROM game_sessions
            JOIN players ON players.game_session_id = game_sessions.id
            WHERE timezone('US/Pacific', completed_at AT TIME ZONE 'utc')::DATE = '#{date.strftime('%Y-%m-%d')}'
            AND winner IS TRUE
          )
      SQL
      )
    end

    def card_stats
      return @card_stats if @card_stats.present?
      @card_stats = Player.find_by_sql(<<~SQL
        SELECT * FROM ( SELECT
          users.username,
          count(distinct players.id) as games_played,
          count(session_frames.id) as cards_played,
          (count(CASE WHEN cards.name = 'lite_metal' THEN 1 END)::decimal / count(distinct players.id)) as lite_metal_crown,
          (count(CASE WHEN cards.name = 'yoko' THEN 1 END)::decimal / count(distinct players.id)) as yoko_crown,
          (count(CASE WHEN cards.name = 'cristin_p' THEN 1 END)::decimal / count(distinct players.id)) as cristin_p_crown,
          (count(CASE WHEN cards.name = 'karl_gitter' THEN 1 END)::decimal / count(distinct players.id)) as gitter_crown,
          (count(CASE WHEN cards.name = 'krypto' THEN 1 END)::decimal / count(distinct players.id)) as krypto_crown,
          (count(CASE WHEN cards.value = 'fixed' THEN 1 END)::decimal / count(distinct players.id)) as fixed_crown,
          (count(CASE WHEN cards.value = 'double' THEN 1 END)::decimal / count(distinct players.id)) as double_crown,
          (count(CASE WHEN cards.value = 'open' THEN 1 END)::decimal / count(distinct players.id)) as open_crown,
          (count(CASE WHEN cards.value = 'sealed' THEN 1 END)::decimal / count(distinct players.id)) as sealed_crown,
          (count(CASE WHEN cards.value = 'once_around' THEN 1 END)::decimal / count(distinct players.id)) as once_around_crown
        FROM players
        JOIN users ON users.id = players.user_id
        JOIN session_frames ON players.game_session_id = session_frames.game_session_id AND session_frames.action = 'card_played'
        JOIN game_sessions ON players.game_session_id = game_sessions.id
        JOIN games ON game_sessions.game_id = games.id
        JOIN session_cards ON session_frames.subject_id = session_cards.id AND session_frames.acting_player_id = players.id
        JOIN cards ON cards.id = session_cards.card_id
        WHERE games.id = 1
        AND game_sessions.completed_at > '2021-01-02'
        GROUP BY users.id ) AS x
        WHERE x.games_played > 5
      SQL
      )
    end
  end
end
