class AddFemaleOnlyToSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :female_only, :boolean, default: false
  end
end
