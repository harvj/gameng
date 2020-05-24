class AddSomeFields < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :name, :string

    create_table :players do |t|
      t.integer :user_id
      t.integer :game_session_id
    end
  end
end
