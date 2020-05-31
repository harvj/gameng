class ChangeSlugToKey < ActiveRecord::Migration[6.0]
  def change
    rename_column :games, :slug, :key
    rename_column :session_decks, :slug, :key
  end
end
