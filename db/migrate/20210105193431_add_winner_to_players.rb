class AddWinnerToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :winner, :boolean, default: false
  end
end
