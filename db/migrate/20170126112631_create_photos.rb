class CreatePhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :photos do |t|
      t.attachment :image
      t.integer :user_id
      t.integer :order, default: 0
      t.boolean :is_primary, default: false
      t.timestamps
    end
  end
end
