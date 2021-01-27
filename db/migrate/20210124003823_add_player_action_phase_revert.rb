class AddPlayerActionPhaseRevert < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :action_phase_revert, :string
  end
end
