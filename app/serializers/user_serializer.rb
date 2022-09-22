class UserSerializer < ActiveModel::Serializer
  attributes :id, :phone_number, :user_name, :bio, :first_name, :last_name,:age, :gender, :city, :state, :is_blocked, :fcm_tokens
  has_many :photos

  def fcm_tokens
    object.devices.pluck(:fcm_token)
  end

end
