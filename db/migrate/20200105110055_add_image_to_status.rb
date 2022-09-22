class AddImageToStatus < ActiveRecord::Migration[5.2]
  def change
    add_attachment :group_statuses, :icon
    add_column     :group_statuses, :user_id, :integer
    add_column     :group_statuses, :status_type, :integer, default: 0
  end
end
