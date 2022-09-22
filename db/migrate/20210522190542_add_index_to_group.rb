class AddIndexToGroup < ActiveRecord::Migration[5.2]
  def change
    add_index :groups, :gender
    add_index :groups, :users_count
    add_index :groups, :min_age
    add_index :groups, :max_age
    add_index :groups, :spot_light_enabled
  end
end
