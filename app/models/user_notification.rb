class UserNotification < ApplicationRecord
  # relations
  belongs_to :user
  belongs_to :notification
end
