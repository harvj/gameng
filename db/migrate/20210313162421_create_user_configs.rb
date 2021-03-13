class CreateUserConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :user_configs do |t|
      t.boolean :show_badge_values, default: true
      t.boolean :show_all_badges, default: true
      t.references :user, index: true
      t.timestamps
    end
  end
end
