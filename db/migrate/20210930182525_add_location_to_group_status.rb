class AddLocationToGroupStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :group_statuses, :latitude, :decimal, precision: 15, scale: 6
    add_column :group_statuses, :longitude, :decimal, precision: 15, scale: 6
    add_column :group_statuses, :address, :string
  end
end
