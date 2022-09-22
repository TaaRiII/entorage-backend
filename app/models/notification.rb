class Notification < ApplicationRecord
  belongs_to :user, optional: true
  has_many :user_notifications
  has_many :users, through: :user_notifications

  def devices_list
    if self.users.present?
      devices = self.users.joins(:devices).pluck(:fcm_token).uniq
    else
      devices = User.joins(:devices).pluck(:'devices.fcm_token')
    end
    return devices
  end
end
