class CreateUserGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :user_groups do |t|
      t.integer :user_id
      t.integer :group_id
      t.boolean :creator, default: false
      t.integer :status, default: 0
      
      t.timestamps
    end
  end
end
