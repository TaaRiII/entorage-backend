class AddIosVersionToAdmin < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :ios_version, :float
  end
end
