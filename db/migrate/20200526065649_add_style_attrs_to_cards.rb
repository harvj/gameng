class AddStyleAttrsToCards < ActiveRecord::Migration[6.0]
  def change
    add_column :cards, :color, :string
    add_column :cards, :icon_class, :string
  end
end
