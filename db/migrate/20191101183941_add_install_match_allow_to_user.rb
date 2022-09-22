class AddInstallMatchAllowToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :instant_match_allow, :integer, default: 1
    add_column :users, :spot_light_allow, :integer, default: 1
    add_column :groups, :spot_light_allow, :integer, default: 1
  end
end
