class AddIndexesToTables < ActiveRecord::Migration[5.2]
  def change
    add_index :users,  :authentication_token
    add_index :photos, :user_id
    add_index :groups, :group_status_id
  end
end
