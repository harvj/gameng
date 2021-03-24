class AddGameIdToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :game_id, :integer
    add_index :players, :game_id
  end
end
