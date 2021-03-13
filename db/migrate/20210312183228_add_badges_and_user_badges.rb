class AddBadgesAndUserBadges < ActiveRecord::Migration[6.0]
  def change
    create_table :badges do |t|
      t.string :name
      t.string :icon_class
      t.string :color
      t.references :game, index: true
      t.timestamps
    end

    create_table :user_badges do |t|
      t.decimal :value
      t.references :as_of_session, index: true
      t.references :badge, index: true
      t.references :user, index: true
      t.timestamps
    end

  end
end
