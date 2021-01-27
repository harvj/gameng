class AddPhasesForPlayersAndSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :action_phase, :string, index: true
    add_column :game_sessions, :special_game_phase, :string
  end
end
