class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.integer :user_id
      t.integer :reporter_id
      t.integer :status, default: 0
      t.text    :reason

      t.attachment :image

      t.timestamps
    end
  end
end
