class FixFrameColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :session_frames, :affected_played_id, :affected_player_id
  end
end
