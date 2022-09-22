class AddDiscardedAtToGroupStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :group_statuses, :discarded_at, :datetime
    add_index :group_statuses, :discarded_at
  end
end
