class CreateFeedBacks < ActiveRecord::Migration[5.2]
  def change
    create_table :feed_backs do |t|
      t.string :reason
      t.string :phone_number
      t.string :first_name

      t.timestamps
    end
  end
end
