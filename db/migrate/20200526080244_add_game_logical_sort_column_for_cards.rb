class AddGameLogicalSortColumnForCards < ActiveRecord::Migration[6.0]
  def change
    add_column :cards, :game_logical_sort, :integer
  end
end
