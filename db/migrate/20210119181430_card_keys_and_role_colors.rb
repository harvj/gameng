class CardKeysAndRoleColors < ActiveRecord::Migration[6.0]
  def change
    add_column :cards, :key, :string, index: true
    add_column :roles, :color, :string, index: true
  end
end
