class HideableBadges < ActiveRecord::Migration[6.0]
  def change
    add_column :badges, :hideable, :boolean, default: true
  end
end
