class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string     :phone_number
      t.string     :user_name
      t.string     :authentication_token
      t.string     :first_name
      t.string     :last_name
      t.text       :bio
      t.date       :dob
      t.integer    :age
      t.integer    :gender
      t.integer    :group_id
      t.decimal    :latitude, precision: 15, scale: 6
      t.decimal    :longitude, precision: 15, scale: 6
      t.string     :city
      t.string     :state
      t.boolean    :creator, default: false
      t.boolean    :is_premium, default: false
      t.timestamps null: false
    end
    add_index :users, :phone_number,                unique: true
    add_index :users, :user_name,                   unique: true
  end
end
