class AddLastUsedToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_used, :datetime
  end
end
