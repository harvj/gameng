class AddToUserBadges < ActiveRecord::Migration[6.0]
  def change
    add_column :user_badges, :active, :boolean, default: true
    add_column :badges, :symbol, :string
    add_column :badges, :display_int, :boolean, default: false
    add_column :badges, :sort_order, :integer
  end
end
