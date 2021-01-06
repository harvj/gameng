class AddGameRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.references :game, index: true
      t.string :icon_class
      t.timestamps
    end

    add_column :players, :role_id, :integer
    add_index :players, :role_id
  end
end
