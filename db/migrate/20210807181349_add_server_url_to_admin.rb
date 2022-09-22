class AddServerUrlToAdmin < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :base_url, :string
  end
end
