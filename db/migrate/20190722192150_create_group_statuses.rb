class CreateGroupStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :group_statuses do |t|
      t.string :name
      t.string :icon
      t.timestamps
    end
  end
end
