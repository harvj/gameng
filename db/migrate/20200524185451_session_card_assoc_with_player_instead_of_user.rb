class SessionCardAssocWithPlayerInsteadOfUser < ActiveRecord::Migration[6.0]
  def change
    rename_column :session_cards, :user_id, :player_id
  end
end
