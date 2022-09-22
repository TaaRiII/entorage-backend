class CreatePlaces < ActiveRecord::Migration[5.2]
  def change
    create_table :places do |t|
      t.string :name
      t.attachment :icon
      t.timestamps
    end

    add_column :groups, :place_id, :integer
  end
end
