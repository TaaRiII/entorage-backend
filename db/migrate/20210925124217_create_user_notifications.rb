class CreateUserNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :user_notifications do |t|
      t.integer :user_id
      t.integer :notification_id

      t.timestamps
    end

    Notification.all.each do |notification|
      if notification.user_id.present?
        notification.user_notifications.create(user_id: notification.user_id)
      end
    end
  end
end
