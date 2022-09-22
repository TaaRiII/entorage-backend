class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.integer :group_status_id
      t.string :name
      t.integer :status, default: 0
      t.decimal    :latitude, precision: 15, scale: 6
      t.decimal    :longitude, precision: 15, scale: 6
      t.string     :city
      t.string     :state
      t.timestamps
    end
  end
end
