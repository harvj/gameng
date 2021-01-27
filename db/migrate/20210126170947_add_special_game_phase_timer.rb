class AddSpecialGamePhaseTimer < ActiveRecord::Migration[6.0]
  def change
    add_column :game_sessions, :special_game_phase_timer, :integer, default: 0
  end
end
