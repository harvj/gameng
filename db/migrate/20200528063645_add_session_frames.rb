class AddSessionFrames < ActiveRecord::Migration[6.0]
  def change
    rename_column :game_sessions, :ended_at, :completed_at

    add_column :players, :moderator, :boolean, default: false
    add_column :players, :score, :integer

    add_column :session_cards, :game_session_id, :integer

    add_index :cards, :game_id
    add_index :game_sessions, :game_id
    add_index :game_sessions, :uid, unique: true
    add_index :games, :slug, unique: true
    add_index :players, :user_id
    add_index :players, :game_session_id
    add_index :session_cards, :game_session_id
    add_index :session_cards, :session_deck_id
    add_index :session_cards, :card_id
    add_index :session_cards, :player_id
    add_index :session_decks, :game_session_id
    add_index :session_decks, [:game_session_id, :slug], unique: true

    create_table :session_frames do |t|
      t.integer :game_session_id, index: true
      t.string :action
      t.integer :active_player_id, index: true
      t.integer :affected_played_id, index: true
      t.integer :value
      t.string :result
      t.integer :subject_id
      t.string :subject_type
      t.index [:subject_id, :subject_type], unique: true
      t.index :action
      t.index [:game_session_id, :action]
      t.timestamps
    end
  end
end
