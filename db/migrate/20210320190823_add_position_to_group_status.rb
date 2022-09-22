class AddPositionToGroupStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :group_statuses, :position, :integer

    [0,2].each do |status_type|
      GroupStatus.where(status_type: status_type).order(:updated_at).each.with_index(1) do |group_status, index|
        group_status.update_column :position, index
      end
    end
  end
end
