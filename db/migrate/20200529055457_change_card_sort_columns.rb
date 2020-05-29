class ChangeCardSortColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :cards, :game_logical_sort, :name_sort
    add_column :cards, :value_sort, :integer
  end
end
