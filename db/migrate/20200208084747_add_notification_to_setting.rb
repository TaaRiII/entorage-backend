class AddNotificationToSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :general, :boolean, default: true
    add_column :settings, :friendship, :boolean, default: true
    add_column :settings, :match, :boolean, default: true
    add_column :settings, :group, :boolean, default: true
    add_column :settings, :chat, :boolean, default: true
  end
end
