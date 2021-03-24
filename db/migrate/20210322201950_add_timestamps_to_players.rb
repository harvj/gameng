class AddTimestampsToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :players, default: Time.zone.now
    change_column_default :players, :created_at, nil
    change_column_default :players, :updated_at, nil
  end
end
