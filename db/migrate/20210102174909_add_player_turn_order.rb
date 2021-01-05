class AddPlayerTurnOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :turn_order, :integer
    add_column :players, :next_player_id, :integer
    add_column :game_sessions, :current_player_id, :integer
    rename_column :session_frames, :active_player_id, :acting_player_id
    add_column :session_frames, :previous_frame_id, :integer
    add_column :session_frames, :state, :string

    add_index :game_sessions, :current_player_id
    add_index :players, :turn_order
    add_index :players, :next_player_id
    add_index :session_frames, :previous_frame_id
    add_index :session_frames, :state
  end
end
