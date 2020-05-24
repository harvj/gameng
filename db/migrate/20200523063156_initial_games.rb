class InitialGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end

    create_table :cards do |t|
      t.integer :game_id
      t.string :name
      t.string :value

      t.timestamps
    end

    create_table :game_sessions do |t|
      t.integer :game_id
      t.string :uid
      t.datetime :started_at
      t.datetime :ended_at
      t.string :status

      t.timestamps
    end

    create_table :session_decks do |t|
      t.integer :game_session_id
      t.string :slug

      t.timestamps
    end

    create_table :session_cards do |t|
      t.integer :session_deck_id
      t.integer :card_id
      t.integer :user_id
      t.datetime :played_at
      t.datetime :discarded_at

      t.timestamps
    end
  end
end
