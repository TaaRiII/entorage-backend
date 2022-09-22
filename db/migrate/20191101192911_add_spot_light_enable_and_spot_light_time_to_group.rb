class AddSpotLightEnableAndSpotLightTimeToGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :spot_light_enabled, :boolean, default: false
    add_column :groups, :spot_light_time, :datetime
  end
end
