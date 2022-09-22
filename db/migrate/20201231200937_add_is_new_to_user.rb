class AddIsNewToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_new, :boolean, default: true
    User.update_all(is_new: false)
  end
end
