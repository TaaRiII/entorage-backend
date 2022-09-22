class AddInstantToMatch < ActiveRecord::Migration[5.2]
  def change
    add_column :matches, :instant, :boolean, default: false
  end
end
