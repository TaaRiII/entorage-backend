class AddIsEverPrimaryToPhoto < ActiveRecord::Migration[5.2]
  def change
    add_column :photos, :is_ever_primary, :boolean, default: false
  end
end
