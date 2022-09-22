class Device < ApplicationRecord
  belongs_to :user
  enum device_type: [:iphone, :android]

  validates :fcm_token,  presence: true
end
