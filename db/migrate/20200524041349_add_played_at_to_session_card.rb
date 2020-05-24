class AddPlayedAtToSessionCard < ActiveRecord::Migration[6.0]
  def change
    add_column :session_cards, :dealt_at, :datetime
    rename_column :game_sessions, :status, :state
  end
end
