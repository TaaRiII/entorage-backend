class CreateMatches < ActiveRecord::Migration[5.2]
  def change
    create_table :matches do |t|
      t.integer :group_id
      t.integer :matcher_id
      t.integer :status
      t.integer :user_id
      t.timestamps
    end
  end
end
