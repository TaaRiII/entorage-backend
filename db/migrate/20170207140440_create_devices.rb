class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.integer :user_id
      t.string  :fcm_token
      t.string  :physical_address
      t.integer :device_type
      t.timestamps
    end
  end
end
