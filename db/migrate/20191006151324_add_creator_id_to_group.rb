class AddCreatorIdToGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :creator_id, :integer
  end
end
